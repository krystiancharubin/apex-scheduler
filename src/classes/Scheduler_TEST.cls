@isTest
public with sharing class Scheduler_TEST {

	public static String CRON_EXP = '0 0 0 15 3 ? 2022';


	@testSetup static void setup(){
		List<Account> accs = TestFactory.createAccount('Account', 10);
		insert accs;
	}

	@isTest static void schedule(){
		CronTrigger ct;

		Test.startTest();

		try {
			Scheduler.schedule('InvalidJob', CRON_EXP, Scheduler_TEST.class);
		} catch (Scheduler.SchedulerException ex) {
			// Invalid Job
		}

		Id jobId = Scheduler.schedule('CustomJob', CRON_EXP, CustomJob.class);

		ct = [
			SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger WHERE id = :jobId
		];

		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);

		Test.stopTest();

		ct = [
			SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger WHERE id = :jobId
		];

		for(Account acc :[SELECT Name FROM Account]){
			System.assertEquals('Updated', acc.Name);
		}

	}

	class CustomJob implements Scheduler.Job {
		public void execute(SchedulableContext sc){
			List<Account> accs = [SELECT Name FROM Account];
			for(Account acc :accs){
				acc.Name = 'Updated';
			}
			update accs;
		}
	}

}