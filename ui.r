library(shiny)
library(shinydashboard)
library(shinythemes)
library(shinyLP)

shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  navbarPage(title = "Klasifikasi Prakiraan Cuaca Menggunakan Algoritma Random Forest",
             navbarMenu("Dataset",
                        tabPanel("Dataset Cuaca",
                                 sidebarLayout(
                                   sidebarPanel(
                                     fileInput("file_dataset", "Masukkan dataset file .csv")
                                   ),
                                   mainPanel(
                                     div(tableOutput("tabel_dataset_cuaca"))
                                   )
                                 )),
                        tabPanel("Dataset Prediksi Cuaca",
                                 sidebarLayout(
                                   sidebarPanel(
                                     fileInput("file_dataset_prediksi", "Masukkan dataset untuk prediksi dengan file .csv")
                                   ),
                                   mainPanel(
                                     tableOutput("tabel_dataset_prediksi")
                                   )
                                 ))),
             tabPanel("Klasifikasi Random Forest",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("var_rf", "Atribut:", choices = "", selected = ""),
                          radioButtons("option_rf", "Pilih Fungsi", choices = c("Tabel", "Akurasi Random Forest","Waktu Pemrosesan", "Aturan","Simple Decision Tree Model"))
                          ),
                        mainPanel(
                          div(verbatimTextOutput("klasifikasi_rf"))
                          )
                        )),
             tabPanel("Prediksi Prakiraan Cuaca",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("var_pred_uji", "Atribut:", choices = "", selected = ""),
                          radioButtons("option_rf_pred", "Pilih Fungsi", choices = c("Tabel", "Prediksi Prakiraan Cuaca"))
                        ),
                        mainPanel(
                          div(verbatimTextOutput("prediksi_rf"))
                        )
                      )))
))