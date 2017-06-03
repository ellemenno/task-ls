package
{
    import pixeldroid.task.SingleTask;

    public class TestTask extends SingleTask
    {
        override protected function performTask():void { /* no-op */ }
        public function do_complete():void { complete(); }
        public function do_fault(message:String):void { fault(message); }
        public function do_progress(percent:Number):void { progress(percent); }
    }
}
