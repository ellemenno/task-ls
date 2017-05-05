package
{
    import loom.Application;
    import loom2d.display.StageScaleMode;
    import loom2d.ui.SimpleLabel;

    //import Task classes here


    public class TaskDemoGUI extends Application
    {

        override public function run():void
        {
            stage.scaleMode = StageScaleMode.LETTERBOX;
            centeredMessage(simpleLabel, this.getFullTypeName());

            demonstrate();
        }

        private function get simpleLabel():SimpleLabel
        {
            return stage.addChild(new SimpleLabel("assets/pixeldroidMenuRegular-64.fnt")) as SimpleLabel;
        }

        private function centeredMessage(label:SimpleLabel, msg:String):void
        {
            label.text = msg;
            label.center();
            label.x = stage.stageWidth / 2;
            label.y = (stage.stageHeight / 2) - (label.height / 2);
        }

        private function demonstrate():void
        {
            trace('demonstration to happen here');
        }
    }
}
