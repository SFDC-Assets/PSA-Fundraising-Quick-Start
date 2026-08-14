/**
 * FQS Outreach Source Code — auto-create service.
 *
 * Given a list of Campaign Ids, upserts one default OutreachSourceCode per campaign
 * using External_Id__c = 'FQS-OSC-{CampaignId18}-DEFAULT' as the idempotency key.
 *
 * Callers:
 *   - FQS_CampaignHierarchyBuilder (bulk, after tactical insert)
 *   - FQS_Campaign_Create_Default_OSCs record-triggered flow (single, when
 *     FQS_Create_Default_Outreach_Sources__c flips to true on a depth-3 campaign)
 *
 * Category → Channel/Platform mapping (see README for rationale):
 *   Annual Giving   → Direct Mail / direct_mail_house
 *   Events          → Email       / other_email
 *   Major Gifts     → Physical    / (blank)
 *   Planned Giving  → Direct Mail / direct_mail_house
 *   Grants          → Direct Mail / direct_mail_house
 *   Corporate Match → Email       / other_email
 *   In-Kind         → Email       / other_email
 *   (blank/other)   → Email       / other_email
 *
 * Status: 'Active' when Campaign.IsActive = true, else 'Inactive'.
 * UsageType: 'Fundraising' (constant).
 * FQS_Message_Channel_Segment__c: NOT written — it's a formula field auto-derived from MessageChannel.
 * SourceCode: auto-generated slug — {ShortSlug}-{YY}-{ChannelCode}.
 */
public with sharing class FQS_OutreachSourceCodeBuilder {

    // ─── Invocable entry for Flow ─────────────────────────────────────────────

    public class BuildRequest {
        @InvocableVariable(required=true label='Campaign Ids' description='Level-3+ Campaign Ids to build defaults for.')
        public List<Id> campaignIds;
    }

    public class BuildResult {
        @InvocableVariable(label='Created Count') public Integer createdCount;
        @InvocableVariable(label='Error Message') public String errorMessage;
    }

    @InvocableMethod(
        category='FQS'
        label='Build Default Outreach Source Codes'
        description='Upserts one default OutreachSourceCode per Level-3+ Campaign passed in.'
    )
    public static List<BuildResult> buildInvocable(List<BuildRequest> requests) {
        BuildResult r = new BuildResult();
        r.createdCount = 0;
        try {
            List<Id> ids = (requests != null && !requests.isEmpty()) ? requests[0].campaignIds : null;
            r.createdCount = buildDefaultsForCampaigns(ids);
        } catch (Exception e) {
            r.errorMessage = e.getMessage();
        }
        return new List<BuildResult>{ r };
    }

    // ─── Bulk service ─────────────────────────────────────────────────────────

    public static Integer buildDefaultsForCampaigns(List<Id> campaignIds) {
        if (campaignIds == null || campaignIds.isEmpty()) return 0;

        List<Campaign> camps = [
            SELECT Id, Name, IsActive, StartDate,
                   FQS_Short_Name__c, FQS_Campaign_Category__c, FQS_Hierarchy_Depth__c
            FROM   Campaign
            WHERE  Id IN :campaignIds
              AND  FQS_Hierarchy_Depth__c >= 3
        ];
        if (camps.isEmpty()) return 0;

        List<OutreachSourceCode> toUpsert = new List<OutreachSourceCode>();
        for (Campaign c : camps) {
            toUpsert.add(buildOne(c));
        }

        Schema.SObjectField extIdField = OutreachSourceCode.External_Id__c;
        Database.UpsertResult[] results = Database.upsert(toUpsert, extIdField, false);

        Integer inserted = 0;
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess() && results[i].isCreated()) inserted++;
        }
        return inserted;
    }

    private static OutreachSourceCode buildOne(Campaign c) {
        String category = c.FQS_Campaign_Category__c;
        ChannelChoice cc = mapCategoryToChannel(category);
        String yy = (c.StartDate != null)
            ? String.valueOf(c.StartDate.year()).right(2)
            : String.valueOf(Date.today().year()).right(2);
        String slug = shortSlugFor(c);
        String sourceCode = slug + '-' + yy + '-' + cc.code;
        String extId = 'FQS-OSC-' + String.valueOf(c.Id).left(15) + '-DEFAULT';

        OutreachSourceCode osc = new OutreachSourceCode();
        osc.Name         = c.Name + ' — ' + cc.channelLabel;
        osc.CampaignId   = c.Id;
        osc.SourceCode   = sourceCode;
        osc.Status       = (c.IsActive == true) ? 'Active' : 'Inactive';
        osc.UsageType    = 'Fundraising';
        osc.MessageChannel = cc.channel;
        if (cc.platform != null) osc.FQS_Platform__c = cc.platform;
        osc.Description  = 'Default outreach source auto-created for ' +
                           (String.isBlank(category) ? 'Tactical' : category) +
                           ' campaign. Clone this record to add channel variants.';
        osc.External_Id__c = extId;
        return osc;
    }

    // ─── Mapping ──────────────────────────────────────────────────────────────

    private class ChannelChoice {
        String channel;       // OutreachSourceCode.MessageChannel picklist value
        String channelLabel;  // human-facing suffix for Name
        String code;          // 2-char code for SourceCode slug
        String platform;      // FQS_Platform__c picklist value (nullable)
        ChannelChoice(String ch, String label, String cd, String plat) {
            channel = ch; channelLabel = label; code = cd; platform = plat;
        }
    }

    private static ChannelChoice mapCategoryToChannel(String category) {
        if (category == 'Annual Giving')   return new ChannelChoice('Direct Mail', 'Direct Mail', 'DM', 'direct_mail_house');
        if (category == 'Events')          return new ChannelChoice('Email',       'Email',       'EM', 'other_email');
        if (category == 'Major Gifts')     return new ChannelChoice('Physical',    'Physical',    'PH', null);
        if (category == 'Planned Giving')  return new ChannelChoice('Direct Mail', 'Direct Mail', 'DM', 'direct_mail_house');
        if (category == 'Grants')          return new ChannelChoice('Direct Mail', 'Direct Mail', 'DM', 'direct_mail_house');
        if (category == 'Corporate Match') return new ChannelChoice('Email',       'Email',       'EM', 'other_email');
        if (category == 'In-Kind')         return new ChannelChoice('Email',       'Email',       'EM', 'other_email');
        return new ChannelChoice('Email', 'Email', 'EM', 'other_email');
    }

    // ─── Slug ─────────────────────────────────────────────────────────────────

    private static String shortSlugFor(Campaign c) {
        if (String.isNotBlank(c.FQS_Short_Name__c)) {
            return normalizeSlug(c.FQS_Short_Name__c).toUpperCase();
        }
        if (String.isBlank(c.Name)) return 'CAMP';
        List<String> parts = c.Name.split('\\s+');
        String s;
        if (parts.size() >= 2) {
            s = safeSubstring(parts[0], 4) + safeSubstring(parts[1], 2);
        } else {
            s = safeSubstring(parts[0], 6);
        }
        s = normalizeSlug(s).toUpperCase();
        if (String.isBlank(s)) s = 'CAMP';
        return safeSubstring(s, 8);
    }

    private static String safeSubstring(String s, Integer n) {
        if (s == null) return '';
        return (s.length() <= n) ? s : s.substring(0, n);
    }

    private static String normalizeSlug(String s) {
        if (s == null) return '';
        return s.replaceAll('[^A-Za-z0-9]', '');
    }
}
