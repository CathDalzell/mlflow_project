#! /usr/bin/env Rscript


library('tidyverse')
library('keras')
library('mlflow')

# Get and prepare the data

c(c(train_data, train_labels), c(test_data, test_labels)) %<-% dataset_reuters(num_words = 10000)

vectorize_sequences <- function(sequences, dimension = 10000) {
  # Create a matrix of 0s
  results <- matrix(0, nrow = length(sequences), ncol = dimension)

  # Populate the matrix with 1s
  for (i in 1:length(sequences))
    results[i, sequences[[i]]] <- 1
  results
}

train_data_vec <- vectorize_sequences(train_data)
test_data_vec <- vectorize_sequences(test_data)

train_labels_vec <- to_categorical(train_labels)
test_labels_vec <- to_categorical(test_labels)

# Validation set


index <- 1:1000

val_data_vec <- train_data_vec[index,]
train_data_vec <- train_data_vec[-index,]

val_labels_vec <- train_labels_vec[index,]
train_labels_vec = train_labels_vec[-index,]

# Set up mlflow

mlflow_set_tracking_uri("https://mlflow.ai-rein.com")
# mlflow_create_experiment("reuters2", artifact_location = "s3://rein-ai-warehouse-clean/mlruns")
mlflow_set_experiment(experiment_name = "reuters2")

powerto <- mlflow_param("powerto", 4, "integer")

# Create the model function

run_model <- function(powerto, epochs = 30){

  network <- keras_model_sequential() %>%
    layer_dense(units = 2^powerto, activation = "relu", input_shape = c(10000)) %>%
    layer_dense(units = 2^powerto, activation = "relu") %>%
    layer_dense(units = 46, activation = "softmax")

  # compile as before
  network %>% compile(
    optimizer = "rmsprop",
    loss = "categorical_crossentropy",
    metrics = c("accuracy")
  )

  # train the model and return the history or just the network

  network %>% fit(
    train_data_vec,
    train_labels_vec,
    epochs = epochs,
    batch_size = 512,
    validation_data = list(val_data_vec, val_labels_vec),
    verbose = FALSE
  ) -> history

  history

}

# Now run the thing

# for (pto in 2:8){
  pto <- powerto
  exp_info <- mlflow_get_experiment()
  with(mlflow_start_run(experiment_id = exp_info$experiment_id), {
    run_model(powerto = pto, epochs = 30) -> output
    min_loss <- min(output$metrics$val_loss)
    mlflow_log_param("powerto", pto)
    mlflow_log_metric("Accuracy", max(output$metrics$val_accuracy))
    mlflow_log_metric("Loss", min_loss)
    mlflow_log_metric("epocoh", which(output$metrics$val_loss == min_loss))

  }
  )
#}
