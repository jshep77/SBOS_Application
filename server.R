library(RSQLite)
library(DBI)
library(shiny)
library(shinyWidgets)
library(sqldf)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(tidyverse)
library(fpp3)
library(GGally)
library(sugrrants)
library(rjson)
library(shiny)
library(fable)
library(data.table)
library(DT)

function(input, output, session) {
  dfByYear <- getStatsByYear()

  observeEvent(input$submitplayer, {
    dfByPlayer <- dbGetQuery(db, paste0("SELECT p.player AS Player, s.year AS Year, s.completions AS Completions, s.pass_attempts AS 'Pass Attempts', s.passing_yards AS 'Passing Yards', s.passing_td AS 'Passing Touchdowns', s.rush_attempts AS 'Rush Attempts', 
                          s.rushing_yards AS 'Rushing Yards', s.rushing_td AS 'Rushing Touchdowns'
                             FROM stats as s
                             LEFT JOIN player as p ON p.player_id = s.player_id
                             WHERE p.player IN ('",input$player1select,"','",input$player2select,"');"))
    
    dfByPlayerStat <- dbGetQuery(db, paste0("SELECT p.player AS Player, SUM(s.passing_yards + s.rushing_yards) AS Yards
                                            FROM stats as s
                                            LEFT JOIN player as p ON p.player_id = s.player_id
                                            WHERE p.player IN ('",input$player1select,"','",input$player2select,"')
                                            GROUP BY p.player;"))
    
    dfPlayer1 <- dfByPlayer %>% filter(Player == input$player1select)
    
    dfPlayer2 <- dfByPlayer %>% filter(Player == input$player2select)
    
    if(nrow(dfPlayer1) > 0 && nrow(dfPlayer2) > 0)
    {
      output$dtByPlayer <- DT::renderDataTable(
        datatable(data = dfByPlayer))
      removeUI(selector = "div:has(> #msgempty)")
      
      output$playergraph <- renderPlot({
        ggplot(dfByPlayerStat, aes(x = Player, y = Yards)) +
          geom_bar(stat="identity")
      })
    }
    else if (nrow(dfPlayer1) > 0 && nrow(dfPlayer2) == 0) {
      output$msgempty <- renderText("Player 2 selection is not valid")
      return(0)
    }
    else if (nrow(dfPlayer1) == 0 && nrow(dfPlayer2) > 0) {
      output$msgempty <- renderText("Player 1 selection is not valid")
      return(0)
    }
    else if (nrow(dfPlayer1) == 0 && nrow(dfPlayer2) == 0) {
      output$msgempty <- renderText("Player selections are not valid")
      return(0)
    }
  })

  observeEvent(input$submitteam, {
    dfByTeam <- dbGetQuery(db, paste0("SELECT t.team as Team, count(DISTINCT s.year) as 'Number of Appearances', MAX(s.year) as 'Last Appearance'
                                        FROM stats AS s
                                        JOIN player as p ON p.player_id = s.player_id
                                        JOIN team as t ON p.team_id = t.team_id
                                        WHERE t.team IN ('",input$team1,"','",input$team2,"')
                                        GROUP BY team;"))
    
    output$dtByTeam <- DT::renderDataTable(
      datatable(data = dfByTeam))
    
    dfByAppear <- dbGetQuery(db, paste0("SELECT t.team AS Team, count(DISTINCT s.year) AS Appearances
                                        FROM stats AS s
                                        JOIN player as p ON p.player_id = s.player_id
                                        JOIN team as t ON p.team_id = t.team_id
                                        WHERE t.team IN ('",input$team1,"','",input$team2,"')
                                        GROUP BY team;"))

    output$barTeam <- renderPlot({
      ggplot(dfByAppear, aes(y=Appearances, x=Team)) +
        geom_bar(stat="identity")
    })
  })

  output$dtByYear <- DT::renderDataTable(
    datatable(data = dfByYear, options = list(pageLength = 25)))
  
  observe({
    # Executes function when rows are selected
    req(input$dtByYear_rows_selected)
    
    # Filters dataframe by selected rows
    selRow <- dfByYear[input$dtByYear_rows_selected,]
    
    # Restructures dataframe to allow plotting
    df <- gather(selRow, Stats, Values, 2:20)
    
    output$barYear <- renderPlot({
      # Converts year to factor instread of int for grouping. Position_dodge() makes group bar chart
      ggplot(df, aes(group=as.factor(year), fill=as.factor(year), y=Values, x=Stats)) +
        geom_bar(position=position_dodge(), stat='identity') +
        labs(fill="Year")
    })
  })
  # end of options
 # end of datatables
  
  output$account_name = renderText({
    "Log In"
  })
  
  makereactivetrigger <- function() {
    rv <- reactiveValues(a = 0)
    list(
      depend = function() {
        rv$a
        invisible()
      },
      trigger = function() {
        rv$a <- isolate(rv$a + 1)
      }
    )
  }
  
  observeEvent(input$submit, {
    if(input$pw != input$pw2)
    {
      output$msg <- renderText("Passwords do not match!")
      return(0)
    }
    sql <- sqlInterpolate(db, "INSERT INTO account (
                          user_name
                          ,password
    )
                          VALUES (
                          ?col1
                          ,?col2
                          );", col1 = input$user, col2 = input$pw)
    dbExecute(db, sql)
    
    removeUI(
      selector = "div:has(> #msg)"
    )
    removeUI(
      selector = "div:has(> #user)"
    )
    removeUI(
      selector = "div:has(> #pw)"
    )
    removeUI(
      selector = "div:has(> #pw2)"
    )
    updateSelectInput(session,"select", "User successfully created!")
    removeUI(
      selector = "div:has(> #select)"
    )
    removeUI(
      selector = "div:has(> #submit)"
    )
    
    output$account_name = renderText({
      paste0(dbGetQuery(
        db, 
        'SELECT user_name FROM account WHERE user_name=?',params = input$user
      ))
    })
  })
  
  observeEvent(input$submit2, {
    output$msg2 <- renderText("")
    login <- dbGetQuery(db, 'SELECT user_name, password FROM account where user_name =?;'
                        ,params = input$login_user)
    
    if(input$login_pw == subset(login, password == input$login_pw))
    {
      output$account_name = renderTable({
        paste0(dbGetQuery(
          db, 
          'SELECT user_name FROM account WHERE user_name=?',params = input$login_user
        ))
      })
    }
    else {
      output$msg2 <- renderText("User doesn't exist or Incorrect Password")
      
      return(0)
    }
    
    
    
    
  })
  observeEvent(input$sign_out, {
    output$account_name = renderText({
      "Log In"
    })
    output$msg3 <- renderText("Signed out successfully.")
  })
  observeEvent(input$signup, {
    updateTabsetPanel(session, "nav",selected = "signuptab")
  })
  observeEvent(input$login, {
    updateTabsetPanel(session, "nav",selected = "logintab")
  })
  observeEvent(input$guest, {
    updateTabsetPanel(session, "nav",selected = "comparisons")
  })
}