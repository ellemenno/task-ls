task-ls
=======

a simple task processing library for loomscript

- [installation](#installation)
- [usage](#usage)
- [building](#building)
- [contributing](#contributing)


## installation

Download the library into its matching sdk folder:

    $ curl -L -o ~/.loom/sdks/sprint34/libs/Task.loomlib \
        https://github.com/pixeldroid/task-ls/releases/download/v0.0.1/Task-sprint34.loomlib

To uninstall, simply delete the file:

    $ rm ~/.loom/sdks/sprint34/libs/Task.loomlib


## usage

0. declare a reference to the Task loomlib in your `.build` file:
    ```ls
    "references": [
        "System",
        "Task"
    ],
    ```
0. import `pixeldroid.cli.Task`
0. ...

### TaskDemo

see an example of using the Task here:

* [TaskDemoCLI.build][TaskDemoCLI.build]
* [TaskDemoCLI.ls][TaskDemoCLI.ls]

you can compile and run the demo from the command line:

    $ cd test
    $ ~/.loom/sdks/sprint34/bin/osx-x64/tools/lsc TaskDemoCLI.build
    $ mv bin/TaskDemoCLI.loom bin/Main.loom
    $ ~/.loom/sdks/sprint34/bin/osx-x64/tools/loomexec

or use Rake:

    $ rake cli


## building

first, install [loomtasks][loomtasks] and the [spec-ls library][spec-ls]

### compiling from source

    $ rake lib:install

this will build the Task library and install it in the currently configured sdk

### running tests

    $ rake test

this will build the Task library, install it in the currently configured sdk, build the test app, and run the test app.


## contributing

Pull requests are welcome!

[loomtasks]: https://github.com/pixeldroid/loomtasks "Rake tasks for working with loomlibs"
[TaskDemoCLI.build]: ./cli/src/TaskDemoCLI.build "build file for the demo"
[TaskDemoCLI.ls]: ./cli/src/demo/TaskDemoCLI.ls "source file for the demo"
[spec-ls]: https://github.com/pixeldroid/spec-ls "a simple spec framework for Loom"
