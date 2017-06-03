package pixeldroid.task
{

    import pixeldroid.task.Task;

    /**
    A task group collects multiple subtasks and tracks their execution as a single task.

    Regular Task delegate callbacks can be added to be notified of state changes for the group as a whole.

    @see pixeldroid.task.Task#addTaskStateCallback
    @see pixeldroid.task.Task#removeTaskStateCallback

    Addidional delegate callbacks can be added to be notified of state changes for individual subtasks:

    @see #addSubTaskStateCallback
    @see #removeSubTaskStateCallback
    */
    public interface TaskGroup extends Task
    {

        /** Add a task to the group */
        function addTask(task:Task):void;

        /** Remove a task to the group */
        function removeTask(task:Task):void;

        /** Access the whole task group. */
        function get tasks():Vector.<Task>;
        function set tasks(value:Vector.<Task>):void;

        /**
        Count the number of sibling tasks in the task group.

        This counts only immediate children of the group, not grandchildren or further.

        The following task tree has a `numTasks` value of 2 when queried at the top-level group:
        ```
        group      (numTasks = 2)
        ├─task     (1)
        └─group    (2)
          ├─task
          ├─task
          ├─group
          │ └─task
          └─task
        ```
        */
        function get numTasks():Number;

        /**
        Count the total number of leaf tasks in the full task group tree.

        The following task tree has a `totalTasks` value of 5 when queried at the top-level group:
        ```
        group      (totalTasks = 5)
        ├─task     (1)
        └─group
          ├─task   (2)
          ├─task   (3)
          ├─group
          │ └─task (4)
          └─task   (5)
        ```
        */
        function get totalTasks():Number;

        /**
        Count the number of currently processed sibling tasks in the task group. Range: `[0, numTasks]`.

        - A task is considered processed if it is complete, disabled, or at fault.
        - This counts only immediate children of the group, not grandchildren or further.
        - This number is comparable to `numTasks` for a completion ratio.
        */
        function get numProcessed():Number;

        /**
        Count the total number of currently processed leaf tasks in the full task group tree.

        - A task is considered processed if it is complete, disabled, or at fault.
        - This number is comparable to `totalTasks` for a completion ratio.
        */
        function get totalProcessed():Number;

        /**
        Connect a callback to a state change delegate.

        The callback will be triggered when any task in the group changes into the target state.
        */
        function addSubTaskStateCallback(state:TaskState, callback:Function):void;

        /** Disconnect a callback from a state change delegate */
        function removeSubTaskStateCallback(state:TaskState, callback:Function):void;
    }
}
