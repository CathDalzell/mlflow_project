# mlflow_project

This repo contains some example MLflow projects.



## The quickstart example.

This simple example uses local files and stores the results locally. For me, the git repo is located at `/Documents/mlflow_project`, and the R code is in `quickstart.R`. The code itself is from the `mlflow` quickstart example on their [website](https://mlflow.org/docs/latest/quickstart.html).

```
library(mlflow)

# Log a parameter (key-value pair)
mlflow_log_param("param1", 5)

# Log a metric; metrics can be updated throughout the run
mlflow_log_metric("foo", 1)
mlflow_log_metric("foo", 2)
mlflow_log_metric("foo", 3)

# Log an artifact (output file)
writeLines("Hello world!", "output.txt")
mlflow_log_artifact("output.txt")
```


To run this from the command line, open a terminal and do:

```
conda activate r-mlflow-1.7.0
mlflow run ~/Documents/mlflow_project -e quickstart.R --no-conda
```

On the Mac, it may be necessary to first do `condat deactivate` if it has already activated the base environment. `mlflow` needs to start from nothing.

To view the results, launch R from the project directory and do:

```
$R
>library('mlflow')
>mlflow_ui()

```

You can launch R from a separate terminal box, but be sure and check the working directory, changing it to the project directory if necessary.

```
$ R
> getwd()
[1] "the_current_work_directory"
> setwd("~/Documents/mlflow_project")
```

## Running from `github`
