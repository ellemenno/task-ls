package
{
    import pixeldroid.task.SingleTask;
    import pixeldroid.task.Task;

    public class TestTask extends SingleTask
    {
        public static function get completingTask():Task { return new CompleteTask(); }
        public static function get disabledTask():Task { return new DisabledTask(); }
        public static function get faultingTask():Task { return new FaultTask(); }
        public static function get progressingTask():Task { return new ProgressTask(); }

        override protected function performTask():void { /* no-op */ }

        public function do_complete():void { complete(); }
        public function do_fault(message:String):void { fault(message); }
        public function do_progress(percent:Number):void { progress(percent); }
    }

    private class CompleteTask extends TestTask
    {
        override protected function performTask():void { do_complete(); }
    }

    private class DisabledTask extends TestTask
    {
        public function DisabledTask() { enabled = false; }
        override protected function performTask():void { do_fault('disabled task should not run'); }
    }

    private class FaultTask extends TestTask
    {
        override protected function performTask():void { do_fault('simulated failure'); }
    }

    private class ProgressTask extends TestTask
    {
        public var numUpdates:Number = 3;

        override protected function performTask():void
        {
            for (var p:Number = 0; p < numUpdates; p++)
                do_progress(p / numUpdates);

            do_complete();
        }
    }
}
