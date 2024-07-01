@IsTest(SeeAllData=false)
public class TX_UniqueNicknameTests {

    @TestSetup
    public static void setupData() {
        Account acc = new Account(
            Name='Test Account',
            AccountNumber='TestCodeAccount'
        );
        insert acc;
        system.assertNotEquals(null,acc.Id);
        Contact con1 = new Contact(
            FirstName='John',
            LastName='Smith',
            Email='john.smith@gmail.com',
            AccountId=acc.Id,
            Department='TestCodeDepartment'
        );
        insert con1;
        system.assertNotEquals(null,con1.Id);

        String profileId = [select Id from Profile where Name='Customer Community Plus User'].Id;
        String nickname = 'puser000'+System.currentTimeMillis();
        User u1 = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = nickname+'@amamama.com',
            CompanyName = 'TEST',
            ContactId=con1.Id,
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u1;
        system.assertNotEquals(null,u1.Id);
    }

    @isTest
    public static void shouldMakeUniqueNickname() {
        User currentUser = new User(Id = UserInfo.getUserId());
        if(UserInfo.getUserRoleId() == null){
            UserRole ur = new UserRole(Name = 'X-TESTING-CEO-00');
            insert ur;
            currentUser.UserRoleId = ur.Id;
            update currentUser;
        }

        System.runAs(currentUser){
            Account acc = [select Id from Account where AccountNumber = 'TestCodeAccount'];
            Contact con1 = [select Id from Contact where Department = 'TestCodeDepartment'];
            String profileId = [select Id from Profile where Name='Customer Community Plus User'].Id;
            Contact con2 = new Contact(
                FirstName='John',
                LastName='Smith2',
                Email='john.smith2@gmail.com',
                AccountId=acc.Id
            );
            insert con2;

            String nickname = [select CommunityNickname from User WHERE ContactId = :con1.Id].CommunityNickname;
            String nickname2 = 'puser001'+System.currentTimeMillis();
            User u2 = new User(
                ProfileId = profileId,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = nickname2+'@amamama.com',
                CommunityNickname=nickname,
                CompanyName = 'TEST',
                ContactId=con2.Id,
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            insert u2;
            nickname = [select CommunityNickname from User where Id = :u2.Id].CommunityNickname;
            System.assertEquals(40, nickname.length());
        }
    }
}