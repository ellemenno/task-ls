package pixeldroid.task
{
    /** Triggered once at task start */
    public delegate TaskStart(task:Task):void;

    /** Triggered zero or more times during task execution, depending on sub-class implementation */
    public delegate TaskProgress(task:Task, percent:Number):void;

    /** Triggered once when a task is aborted */
    public delegate TaskFault(task:Task, message:String):void;

    /** Triggered once at task finish */
    public delegate TaskComplete(task:Task):void;

    /**
    A task performs some work when the `start()` method is called.

    Add delegate callbacks to be notified of state changes:
    - Supply a TaskStart callback for TaskState.RUNNING
    - Supply a TaskProgress callback for TaskState.REPORTING
    - Supply a TaskFault callback for TaskState.FAULT
    - Supply a TaskComplete callback for TaskState.COMPLETED

    Note that subclasses decide whether and how granularly to report progress.
    */
    public interface Task
    {
        /** Query the current state of the Task */
        function get currentState():TaskState;

        /** When `true`, the task is active */
        function get enabled():Boolean;
        function set enabled(value:Boolean):void;

        /** A label to distinguish the task. */
        function get label():String;
        function set label(value:String):void;

        function addCallback(state:TaskState, callback:Function):void
        function removeCallback(state:TaskState, callback:Function):void

        /** Trigger the task to begin processing */
        function start():void;
    }
}
