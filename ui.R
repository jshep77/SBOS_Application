navbarPage(id = "nav", "Superbowl Offense Stat Check",
           tags$head(
             includeCSS("styles.css")
             
           )
           ,tabPanel(value="hometab", "Home",
                     fluidPage(
                       fluidRow(
                         br()
                         ,br()
                         ,br()
                         ,br()
                         ,"Get your Superbowl Offense stats at the click of a button!"
                         ,align='center'
                         ,style="color: #FFFFFF; 
                         font-size: 20px;"
                         ,br()
                         ,br()
                       ),
                       fluidRow(div(
                         div(style="display: inline-block; width: 100px ;"
                             ,actionButton("signup", "Sign Up"
                                           ,style="color: #FFFFFF; 
                                           background-color: #ED0015; 
                                           border-color: #FFFFFF"
                             )
                         ),
                         div(style="display: inline-block; width: 100px ;"
                             ,actionButton("login", "Log In"
                                           ,style="color: #FFFFFF; 
                                           background-color: #ED0015; 
                                           border-color: #FFFFFF"
                             )
                         ),
                         div(style="display: inline-block; width: 150px ;"
                             ,actionButton("guest", "Continue as Guest"
                                           ,style="color: #FFFFFF; 
                                           background-color: #ED0015; 
                                           border-color: #FFFFFF"
                             )
                         )
                       ), align = 'center'
                       ) #Row
                     ) #Page
           ), #Panel      
           
           tabPanel(value="signuptab", ""
                    ,setBackgroundColor(color = c("#003A77")),
                    fluidRow(textInput("user","User Name:")
                             , align = 'center'
                             , style="color:white"),
                    fluidRow(textInput("pw","Password:")
                             , align = 'center'
                             , style="color:white"),
                    fluidRow(textInput("pw2","Re-Type Password:")
                             , align = 'center'
                             , style="color:white"),
                    fluidRow(selectInput("select", "Favorite Team", 
                                         choices = teams$team, selected = "(none)")
                             , align = 'center'
                             , style="color:white"),
                    fluidRow(actionButton("submit", "Submit", icon("paper-plane") 
                                          ,style="color: #FFFFFF; 
                                          background-color: #ED0015; 
                                          border-color: #FFFFFF")
                             ,align = 'center'),
                    fluidRow(tableOutput('dbtable'), align = 'center',style="color: #FFFFFF;"),
                    fluidRow(textOutput('msg'), align = 'center',style="color: #FFFFFF;")
                    
                    
                    ),
           tabPanel(value="logintab", uiOutput("account_name")
                    ,setBackgroundColor(color = c("#003A77")),
                    fluidRow(div(
                      div(textInput("login_user","User Name:")
                          , align = 'center'
                          , style="color:white"),
                      div(textInput("login_pw","Password:")
                          , align = 'center'
                          , style="color:white"))
                      
                    ),
                    fluidRow(actionButton("submit2", "Submit", icon("paper-plane") 
                                          ,style="color: #FFFFFF; 
                                          background-color: #ED0015; 
                                          border-color: #FFFFFF")
                             ,align = 'center'),
                    fluidRow(textOutput('msg2'), align = 'center',style="color: #FFFFFF;"),
                    fluidRow(tableOutput('check'), align = 'center',style="color: #FFFFFF;")
                    
                    
                    )
           ,
           navbarMenu("",title = uiOutput("logout_name")
                      , tabPanel(value="signouttab", "Signout",
                                 fluidRow(actionButton("sign_out", "Click here to Sign Out" 
                                                       ,style="color: #FFFFFF; 
                                                       background-color: #ED0015; 
                                                       border-color: #FFFFFF")
                                          ,align = 'center'),
                                 fluidRow(textOutput('msg3'), align = 'center',style="color: #FFFFFF;")                                                    
                                 )),
           
           tabPanel(value="comparisons", ""
                    ,setBackgroundColor(color = c("#003A77")),
                    fluidPage(id = "comptab",
                              tabsetPanel(
                                #compare by year
                                tabPanel(value="cby","Compare By Year",
                                         tags$h2("Click rows to select years to compare", style="color: #FFFFFFF;"),
                                         DT::dataTableOutput("dtByYear"),
                                         plotOutput("barYear"), height = 800),
                                #compare by team
                                tabPanel(id="cbt","Compare By Team", 
                                         fluidRow(selectInput("team1", "Select A Team", 
                                             choices = teams$team, selected = "(none)"),
                                         selectInput("team2", "Select A Team to Compare",
                                             choices = teams$team, selected = "(none)"),
                                             align = 'center',
                                             style="color:white"),
                                         fluidRow(actionButton("submitteam", "Click here to Compare Teams" 
                                                       ,style="color: #FFFFFF; 
                                                       background-color: #ED0015; 
                                                       border-color: #FFFFFF")
                                                       ,align = 'center'),
                                          DT::dataTableOutput("dtByTeam"),
                                          plotOutput("barTeam"), height=800),
                                #compare by player
                                tabPanel(id="cbp","Compare By Player",
                                         fluidRow(textInput("player1select", "Select A Player", placeholder='i.e. Patrick Mahomes'),
                                                  align = 'center',
                                                  style="color:white"), 
                                         fluidRow(textInput("player2select", "Select A Player to Compare", placeholder = 'i.e. Tom Brady'),
                                                  align = 'center',
                                                  style="color:white"),
                                         fluidRow(actionButton("submitplayer", "Click here to compare Players"
                                                               ,style="color: #FFFFFF; 
                                                               background-color: #ED0015;
                                                               border-color: #FFFFFF")
                                                  ,align = 'center'), 
                                         fluidRow(textOutput('msgempty'), align = 'center',style="color: #FFFFFF;"),
                                          DT::dataTableOutput("dtByPlayer"), plotOutput("playergraph"), height=900
                                      )
                              )
                ), align="left"
      )
)
