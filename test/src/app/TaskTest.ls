package
{
    import system.application.ConsoleApplication;
    import system.Process;

    import pixeldroid.bdd.SpecExecutor;

    import TaskSpec;


    public class TaskTest extends ConsoleApplication
    {
        override public function run():void
        {
            SpecExecutor.parseArgs();

            var returnCode:Number = SpecExecutor.exec([
                TaskSpec
            ]);

            Process.exit(returnCode);
        }
    }

}
