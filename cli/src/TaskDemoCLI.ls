package
{
    import system.application.ConsoleApplication;

    //import Task classes here


    public class TaskDemoCLI extends ConsoleApplication
    {
        override public function run():void
        {
            trace(this.getFullTypeName());

            var arg:String;
            for (var i = 0; i < CommandLine.getArgCount(); i++)
            {
                trace('arg', i, ':', CommandLine.getArg(i));
            }
        }
    }
}
