public class TX_UniqueNicknameHelper {

    public static List<User> getMatchingUsers(List<User> triggerNew) {
        Set<String> nicknames = new Set<String>();
        for(User u : triggerNew) {
            nicknames.add(u.CommunityNickname);
        }
        return [
            select Id, CommunityNickname 
            from User 
            where CommunityNickname IN :nicknames
        ];
    }
    
    // there is unique check on username as well, so we reliably fallback on this
    public static String getUniqueNickname(User u) {
        String userName = u.Username.replace('@', '_');
        String timeStamp = String.valueOf(Datetime.now().getTime());

        if(userName.length() + timeStamp.length() > 40) userName = userName.subString(0, 40 - timeStamp.length());

        return userName + timeStamp;
    }
}