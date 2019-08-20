library(shiny)
library(caret)
library(AppliedPredictiveModeling)
library(rpart)
library(rpart.plot)
library(partykit)
library(rattle)
library(ggplot2)
library(randomForest)
library(rsample)
library(lattice)
library(grid)
library(gridExtra)
library(mlbench)

shinyServer(function(input, output, session){
  #load dataset cuaca
  input_dataset_cuaca <- reactive({
    infile_dataset_cuaca <- input$file_dataset
    req(infile_dataset_cuaca)
    data.frame(read.csv(infile_dataset_cuaca$datapath))
  })
  
  #load dataset prediksi cuaca
  input_dataset_prediksi <- reactive({
    infile_dataset_prediksi <- input$file_dataset_prediksi
    req(infile_dataset_prediksi)
    data.frame(read.csv(infile_dataset_prediksi$datapath))
  })
  
  output$tabel_dataset_cuaca <- renderTable({
    df_dataset <- input_dataset_cuaca()
  })
  
  output$tabel_dataset_prediksi <- renderTable({
    df_prediksi <- input_dataset_prediksi()
  })
  
  #klasifikasi rf
  observeEvent(input$file_dataset, {
    updateSelectInput(session, inputId = "var_rf", choices = names(input_dataset_cuaca()))
  })
  
  rf_out_dataset <- reactive({
    df_dataset <- input_dataset_cuaca()
    table_dataset <- table(df_dataset[, input$var_rf])
    
    if (input$option_rf == "Tabel"){
      return(table_dataset)
    }
    
    #data training & testing
    rf_intrain <- createDataPartition(y = df_dataset[, input$var_rf], p = 0.7, list = FALSE)
    rf_training <- df_dataset[rf_intrain,]
    rf_testing <- df_dataset[-rf_intrain,]
    
    #klasifikasi random forest
    rf_start_time <- proc.time()
    {
      akurasirf_cuaca <- train(Cuaca~., method = "rpart", data = rf_training)
      predictionrf_cuaca <- predict(akurasirf_cuaca, newdata = rf_testing)
    }
    rf_end_time <- proc.time()
    rf_execution_time <- rf_end_time - rf_start_time
    
    if (input$option_rf == "Akurasi Random Forest"){
      return(confusionMatrix(predictionrf_cuaca, rf_testing$Cuaca))
    }
    
    if (input$option_rf == "Waktu Pemrosesan"){
      return(rf_execution_time)
    }
    
    if (input$option_rf == "Aturan"){
      return(summary(akurasirf_cuaca))
    }
    
    #simple decision tree model
    modfitrf_cuaca <- caret::train(Cuaca~., method = "rpart", data = rf_training)
    
    if (input$option_rf == "Simple Decision Tree Model"){
      return(rattle::fancyRpartPlot(akurasirf_cuaca$finalModel))
    }
    })
  
  output$klasifikasi_rf <- renderPrint({
    rf_out_dataset()
  })
  
  #Prediksi rf
  observeEvent(input$file_dataset_prediksi, {
    updateSelectInput(session, inputId = "var_pred_uji", choices = names(input_dataset_prediksi()))
  })
  
  rf_out_prediksi <- reactive({
    df_dataset <- input_dataset_cuaca()
    df_prediksi <- input_dataset_prediksi()
    
    tab_rf_pred <- table(df_prediksi[, input$var_pred_uji])
    
    if (input$option_rf_pred == "Tabel"){
      return(tab_rf_pred)
    }
    
    modfit_cuaca_uji <- train(Cuaca~., method = "rpart", data = df_dataset)
    predmodujicuaca <- predict(modfit_cuaca_uji, newdata = df_prediksi)
    df_prediksi <- cbind(df_prediksi, Prediksi_Cuaca = predmodujicuaca)
    if (input$option_rf_pred == "Prediksi Prakiraan Cuaca"){
      return(df_prediksi)
    }
  })
  
  output$prediksi_rf <- renderPrint({
    rf_out_prediksi()
  })
  })