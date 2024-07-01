/* Handler class for External Record trigger
 *
 * Revision History:
 *
 * Version     Author           Date         Description
 * 1.0         Ajinkya H        23/02/2016   Initial Draft
 */

public class ExternalRecordTriggerHandler {

    public static Boolean isRuleRecursion = true;
    private static final String EXTERNAL_RECORD_OBJECT = 'JIENS__External_Record__c';

    public static void onAfterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        // Call Rule Engine Controller for after update event
        if(isRuleRecursion ) {
            JIENS.RuleEngineController.TriggerContextNew(newMap,
                                                         oldMap,
                                                         EXTERNAL_RECORD_OBJECT,
                                                         Trigger.isExecuting,
                                                         Trigger.isInsert,
                                                         Trigger.isUpdate,
                                                         Trigger.isDelete,
                                                         Trigger.isAfter,
                                                         isRuleRecursion);
            isRuleRecursion = false;
        }
    }
}