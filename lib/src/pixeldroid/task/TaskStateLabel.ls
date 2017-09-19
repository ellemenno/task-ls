package pixeldroid.task
{
    import pixeldroid.task.TaskState;


    public class TaskStateLabel
    {
        public static function toLabel(state:TaskState):String
        {
            switch (state)
            {
                case TaskState.UNSTARTED: return 'unstarted';
                case TaskState.RUNNING: return 'running';
                case TaskState.COMPLETED: return 'completed';
                case TaskState.FAULT: return 'fault';
            }

            return '???';
        }
    }
}
