@isTest
public class TasksCronJobTest {
    
    @testSetup
    static void setup() {
        List<Task> tasks = new List<Task>();
        
        tasks.add(new Task(Subject = 'Test Task 1', Description = 'Event Code 43 not found'));

        insert tasks;
    }
    
    @isTest
    static void testExecute_MatchedTasks() {
        Test.startTest();
        
        TasksCronJob cronJob = new TasksCronJob();
        cronJob.execute(null); 
        
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Description FROM Task];

        List<Task> matchedTasks = new List<Task>();
        for (Task t : tasks) {
            if (t.Description.contains('Event Code 43 not found')) {
                matchedTasks.add(t);
            }
        }

        System.assertEquals(0, matchedTasks.size(), 'There should be 0 matched task with "Event Code 43 not found" in the description');       
}

}