![Public Sector Accelerators logo](/docs/Logo_GPSAccelerators_v01.png)
# Fundraising Quick Start

<!-- TODO: replace with published short-link once the accelerator is listed -->
https://sfdc.co/fundraising-quick-start

## Description

The Fundraising Quick Start helps nonprofit organizations set up the foundational fundraising features of Nonprofit Cloud using best practices, automation, and clearer setup steps. It addresses the most common data quality, reporting, and usability gaps in a standard Nonprofit Cloud Fundraising implementation — reducing the manual configuration work required of admins and the manual data entry required of gift-entry, development, and finance staff.

Gift Transactions and Gift Commitments

* Guidance and automation to keep Gift Transaction and Gift Commitment data clean, consistent, and ready for reporting — including sensible defaults for category, in-kind, matched, and recurring gift attributes.
* Dynamic Lightning record pages for Gift Transactions and Gift Commitments that surface the right fields, related lists, and quick actions based on gift context (one-time vs. recurring, in-kind vs. cash, matched vs. unmatched).
* Change-tracking on Gift Commitments via the Gift Commitment Change Attribute Log to give development and finance staff an auditable history of commitment adjustments.

Designations, Soft Credits, and Tributes

* Guided setup and automation around Gift Designations, Gift Default Designations, and Gift Transaction Designations to keep restricted vs. unrestricted revenue categorized correctly.
* Automation and page-layout support for Gift Soft Credits and Gift Default Soft Credits so that recognition credit can be captured alongside hard credit without double-counting revenue.
* Support for Gift Tributes (in honor of / in memory of) with a dynamic record page and standardized fields for acknowledgement handling.

Refunds, Adjustments, and Payment Instruments

* A supported pattern for Gift Refunds with a dedicated record page, so refunds and adjustments can be entered without corrupting historical gift totals.
* Guidance for using Payment Instrument records to represent donor payment methods consistently across one-time and recurring gifts.

Outreach and Donor Summaries

* Configuration for Outreach Source Code and Outreach Summary records so that appeals, sources, and channels can be tied back to Gift Transactions for attribution reporting.
* A curated Donor Gift Summary record page that gives fundraisers a single-glance view of a donor's giving history, largest gift, most recent gift, and recurring status.

General Improvements

* A dedicated **Fundraising Quick Start** Lightning app with the right tabs, dynamic pages, and utility bar wired up for gift-entry and development team workflows.
* A curated `FQS_Fundraising` Campaign record type and Campaign dynamic page tuned for nonprofit fundraising appeals rather than sales campaigns.
* Data model improvements — help text, descriptions, and picklist cleanups on Gift Transaction, Gift Commitment, Gift Designation, and related standard fields — reducing support burden and improving clarity for admins and end users.
* A `FQS_Donor_Tier__mdt` custom metadata type for classifying donors into three named donor tiers (Entry, Mid, Major) without hard-coding thresholds in flows or reports, plus an **FQS Setup** screen flow (launched from the Setup tab or utility bar in the Fundraising Quick Start Lightning app) that lets admins edit tier thresholds, per-tier credit-type (hard-only vs hard + soft), and stewardship routing without opening Setup → Custom Metadata Types.
* A `FQS_Custom_Fields` permission set to assist admins in providing access to the accelerator's custom fields and functionality.

### Included Assets

An unmanaged package (link in the installation section of this document; metadata is also found in the [/force-app/main/default/](/force-app/main/default/) folder) that includes:

* A Lightning app: **Fundraising Quick Start**
* Dynamic Lightning record pages for: Campaign, Gift Transaction, Gift Commitment, Gift Commitment Schedule, Gift Designation, Gift Default Designation, Gift Transaction Designation, Gift Soft Credit, Gift Default Soft Credit, Gift Tribute, Gift Refund, Gift Commitment Change Attribute Log, Donor Gift Summary, Outreach Source Code, Outreach Summary, Payment Instrument, and Opportunity
* Custom fields, help text, and description updates on standard Fundraising objects (Gift Transaction, Gift Commitment, Gift Designation, and related)
* A custom Campaign record type (`FQS_Fundraising`) for fundraising campaigns
* A custom metadata type (`FQS_Donor_Tier__mdt`) for donor tier definitions
* Custom quick actions and path assistants for gift-entry workflows
* Two permission sets: **FQS Custom Fields** (grants FLS on FQS custom + patched fields) and **FQS Campaign Fields** (grants read/edit on standard Campaign fields such as StartDate, EndDate, ParentId, ExpectedRevenue, etc.)
* Duplicate and Matching Rules on Account and Contact — three warn-not-block Duplicate Rules (`FQS_Account_Organization_Dupe`, `FQS_Account_Person_Dupe`, `FQS_Contact_Dupe`) backed by three Matching Rules (`FQS_Account_Organization_Match` on Name + BillingCity, `FQS_Account_External_Id_Match` on `External_Id__c`, `FQS_Contact_Individual_Match` on FirstName + LastName + Email). All ship active and coexist with the standard Salesforce rules; see the Establish Data Integrity Guardrails post-install section for tuning.

This accelerator includes the following additional documents:

* Metadata Inventory <!-- TODO: link once published in /docs/ -->
* Flow Descriptions <!-- TODO: link once published in /docs/ -->
* Data Dictionary <!-- TODO: link once published in /docs/ -->

### Documentation Including

This readme file

<!-- TODO: add Salesforce Help / Trailhead links relevant to Fundraising once curated. Examples to consider:
* Nonprofit Cloud Fundraising documentation
* Gift Entry / Gift Batch Trailhead module
* Recurring Donations documentation
* Gift Designation / Restriction documentation
-->

### License Requirements

* Agentforce Nonprofit / Nonprofit Cloud (Fundraising enabled)

### Accelerator or Technology-Specific Assumptions

This accelerator was built and designed for nonprofit organizations that are just beginning to use the Fundraising features of Agentforce Nonprofit / Nonprofit Cloud. It is intended to help a Salesforce Administrator not only set up Fundraising but also to understand the functionality.

It is recommended (but not required) that the [Stakeholder Management Quick Start](https://sfdc.co/stakeholder-quick-start) be installed first, since Fundraising Quick Start assumes clean Account / Person Account / Household data as its starting point. Where Fundraising Quick Start expects specific stakeholder configuration, this readme calls it out explicitly.

## Implementation Steps

### Determine Install Location

1. Determine where you will install the unmanaged package:
   1. **New Customer:** If you are a new customer we encourage you to install the Fundraising Quick Start accelerator into a base org available here: [https://www.salesforce.com/form/sfdo/signup/nonprofit/nonprofit-cloud-base-trial/](https://www.salesforce.com/form/sfdo/signup/nonprofit/nonprofit-cloud-base-trial/)
   2. **Existing Customer:** Create either a sandbox or a scratch org. It is possible to install into production but that is only advised if you have no existing Fundraising configuration and have already confirmed all elements of the Fundraising Quick Start are applicable.

2. Review this file and other appropriate documentation linked in this document. <!-- TODO: add a Vidyard walkthrough link once recorded, e.g. https://salesforce.vidyard.com/watch/... -->

### Before You Install

*Notice: Fundraising Quick Start depends on Nonprofit Cloud Fundraising being enabled and on a small set of Stakeholder-Management-adjacent settings (Person Accounts, Group Membership) being in place. If you have not yet installed the Stakeholder Management Quick Start, complete the "Before You Install" section of that accelerator first, then continue here.*

1. **Enable CRM Analytics for Nonprofit Cloud / Fundraising Cloud**

   CRM Analytics (formerly Einstein Analytics / Wave) is bundled with Agentforce for Nonprofits and Nonprofit Cloud licenses — no additional purchase required — but the platform must be turned on in Setup before installing this package. Several downstream components in the accelerator assume the Nonprofit Cloud / Fundraising CRMA app is provisioned; if CRMA is not enabled at install time, analytics-adjacent components may fail to deploy or resolve.

   1. From **Setup**, in the **Quick Find** box, enter **Analytics** or **CRM Analytics**, and follow the prompts to enable the platform for the org.
   2. Provision the **Nonprofit Cloud** / **Fundraising** CRMA app(s) once the platform is enabled.
   3. Verify enablement by launching the **Analytics Studio** app from the App Launcher before continuing.

   Supporting documentation:

   * [Enable CRM Analytics Platform](https://help.salesforce.com/s/articleView?id=sf.bi_help_setup.htm&type=5)
   * [CRM Analytics for Nonprofit Cloud](https://help.salesforce.com/s/articleView?id=sfdo.npc_analytics_overview.htm&type=5)

2. **Assign the Default Workflow User**

   Fundraising Quick Start installs a set of flows and depends on flows already delivered with Nonprofit Cloud Fundraising. When a flow runs on a scheduled path, an asynchronous step, or a workflow-rule-driven email alert or field update, Salesforce needs a fallback user context if it cannot determine the running user. That fallback is the **Default Workflow User**. Set this **before** installing the package so every FQS automation has a stable identity from the first deploy.

   1. **Choose the right user for this role**
      1. Use a dedicated integration user or a stable admin service account — for example, an "Automation Admin" or "Nonprofit Ops" user — that stays licensed and active across staff turnover.
      2. Do **not** use a personal user account (an executive director, development director, or the admin who happens to be installing this package). If that person leaves the organization and their user is deactivated, every automation that fell back to this user will start failing.
      3. Confirm the chosen user has an active Salesforce license and, at minimum, the same object and field access required by the flows in this accelerator (Gift Transaction, Gift Commitment, Gift Designation, Gift Soft Credit, Gift Refund, Gift Tribute, and Outreach objects).

   2. **Open Process Automation Settings**
      1. From **Setup**, in the **Quick Find** box, enter **Process Automation Settings**, and then select **Process Automation Settings**.

   3. **Assign the Default Workflow User**
      1. In the **Default Workflow User** field, click the lookup icon.
      2. Search for and select the dedicated integration or admin service user you chose in step 1.
      3. Confirm the user's name now appears in the **Default Workflow User** field.

   4. **Save the setting**
      1. Click **Save**.
      2. Confirm the page reloads with the assigned user still displayed.

   5. **Document the assignment**
      1. Record the assigned user in your internal admin runbook (or the Fundraising Quick Start post-install checklist) so future admins know which account backs your automations.
      2. Add the assigned user to your standard user-lifecycle review so it is not accidentally deactivated when its owner rotates off the team.

   *Notice: If the Default Workflow User is deactivated, has their license removed, or is deleted, workflow-rule email alerts and any flow paths that fall back to this user will fail — often silently. Salesforce does not automatically reassign the setting. Treat this user like a production integration account: monitor it, and update this setting immediately if the user must be replaced.*

   Supporting documentation:

   * [Default Workflow User](https://help.salesforce.com/s/articleView?id=platform.customize_wfdefaultuser.htm&type=5)
   * [Process Automation Settings](https://help.salesforce.com/s/articleView?id=platform.customize_wf.htm&type=5)
   * [How Does a Flow's Running User Work](https://help.salesforce.com/s/articleView?id=sf.flow_distribute_system_mode.htm&type=5)
   * [Prepare to Install Nonprofit Cloud](https://help.salesforce.com/s/articleView?id=industries.NPC_prepare_install.htm&type=5)

3. **Enable Nonprofit Cloud Fundraising and Review Fundraising Settings**

   Fundraising Settings is a single Setup page with a large surface area of toggles, thresholds, and integration knobs. Review the whole page carefully during install — several defaults are aggressive (retry counts, validation pauses) and several depend on assets that don't exist yet at pre-install time (Duplicate Rules, custom external-ID fields).

   1. From **Setup**, in the **Quick Find** box, enter **Fundraising**, and select **Fundraising Settings**.

   2. **Fundraising Tools for Everyone** — turn on. This is the master switch that lights up Fundraising for all licensed users.

   3. **General Fundraising Settings** — review the three retry thresholds and two automation checkboxes below with your finance / gift-ops team before go-live:
      * **Installment Extension Day Count** (default 1) — how many days beyond a scheduled installment date the platform waits before flagging the installment as late.
      * **Lapsed Unpaid Transaction Count** (default 3) — how many consecutive unpaid installments before the parent Gift Commitment is marked Lapsed.
      * **Failing Transaction Count** (default 1) — how many failed transactions before the parent Gift Commitment is flagged Failing.
      * **Create Recurring Schedule Transaction** — controls whether the platform auto-fans-out scheduled Gift Transaction records ahead of the payment date. FQS assumes this is **on**; several FQS reports and the Gift Acknowledgement flow depend on Expected-status GTs being present.
      * **Auto Close Recurring Commitment** — auto-closes recurring commitments when their end date passes. Leave on unless your finance team explicitly manages recurring closure by hand.

   4. **Gift Entry Grid** — turn **on**. FQS ships four Gift Entry Grid templates (`FQS_Event_Registrations`, `FQS_Individual_Outright_Gifts`, `FQS_Pledge_Payments`, `FQS_Single_Payment_Pledges`) and the Home Page walkthrough (§XII, accordion item 4) uses the Grid as the primary batch-entry surface. Leaving this toggle off hides the Grid tab and the shipped templates aren't reachable.

   5. **NextGen Commitment Processing** — leave off unless your org has high recurring-gift volume and has coordinated the switch with Salesforce Support. FQS is authored against the current commitment processing engine; NextGen changes fanout timing.

   6. **Gift Entry — External ID** — leave blank at pre-install. FQS does not ship a donor-matching external-ID field; revisit this after go-live only if you introduce a custom donor-matching field.

   7. **Donor Matching Method** — set to **No Matching** at pre-install. The **Duplicate Management Rules** option depends on the FQS Duplicate Rules being deployed and active, which happens during package install. Return to this setting during post-install and flip to **Duplicate Management Rules** once the `FQS_Contact_Dupe` and `FQS_Account_*_Dupe` rules are confirmed active.

   8. **Philanthropic Research Topics in Agentforce** — leave off unless Agentforce is provisioned and your org has explicitly opted in to Einstein Generative AI features. Consumes Einstein Requests.

   9. **Gift Planning and Agreements** — turn on **Gift Planning** and **Gift Agreements** if your org handles planned gifts (bequests, trusts, endowments) or formal gift-agreement contracts. Both are independent switches; turn on only what you'll actually use.

   10. **Configure Data Cloud Access** — click only if your org has Data Cloud provisioned and plans to segment or activate on Fundraising data. No-op otherwise.

   11. **Pause Gift Validations** — leave all three toggles **off** for normal operation:
       * Pause Gift Transaction Validations
       * Pause Gift Commitment Validations
       * Pause Gift Commitment Schedule Validations

       *Notice: These pauses disable platform validation rules on the named objects. Only turn them on during a supervised bulk-import or migration window, and turn them back off before go-live. Leaving any of them on in production corrupts data integrity over time — validation rules exist to catch scheduling and totals errors that silently break rollups downstream.*

   Supporting documentation:

   * [Enable Fundraising](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_enable_fundraising.htm&type=5)
   * [Fundraising Settings Reference](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_settings_reference.htm&type=5) <!-- verify article id before ship -->

4. **Assign the Fundraising_Admin Permission Set Group**
   1. From Setup, in the Quick Find box, enter **Permission Set Groups**, and then select **Permission Set Groups**.
   2. Click **Recently Viewed** and then select **All Permission Set Groups**.
   3. Click the permission set group name **Fundraising_Admin** in the list view.
   4. Click **Manage Assignments** and then **Add Assignments**.
   5. Select each user to whom you want to assign the group, and then click **Next**.
   6. Optionally, select an expiration date for the user assignment to expire.
   7. Click **Assign**.

5. **Enable Person Accounts for Fundraising** (skip if already enabled via Stakeholder Management Quick Start)
   1. From **Setup**, in the **Quick Find** box, enter **Person Accounts**, and follow the steps on the Setup page.
   2. Click **View Org Impacts**, review the Org Impact Acknowledgement, and click **Enable Person Accounts**.
   3. Once Person Accounts is enabled, follow [Enable Person Accounts for Fundraising](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_enable_person_accounts_for_fundraising.htm&type=5) to complete the fundraising-specific configuration (record-type mapping, layout adjustments).
   4. **Recommended:** rename the platform-created Person Account record type to **Individual** for consistency with the Stakeholder Management Quick Start and with the everyday-language conventions used across both accelerators. From **Setup → Object Manager → Person Account → Record Types**, click **Person Account**, then **Edit**, and set the Record Type Label and Record Type Name to `Individual`. Suggested description: *Select this for any individual. This will create a person account.* You can pick a different name if your organization prefers — just apply the same choice consistently, since a later post-install step (§IV) grants record type visibility on that same record type by name.

   *Notice: Person Accounts is a one-way switch — once enabled it cannot be disabled without Salesforce Support involvement. Coordinate with your finance and stakeholder-management leads before enabling.*

6. **Plan Your Field History Tracking Strategy**

   Field history tracking records old and new values when a field changes, creating an auditable change log that is invaluable for gift-entry audits, finance reconciliations, and donor-relationship reviews. **Plan your tracking strategy before you install and start entering data** — Salesforce only begins tracking from the moment you enable it; there is no way to retroactively capture changes that happened before tracking was turned on.

   1. **Understand the platform limits**
      1. Each object supports a maximum of **20 fields** tracked simultaneously.
      2. History records are retained for **18 months** by default. If your finance team, auditors, or major-donor stewardship practices require longer retention, evaluate Salesforce Shield Field Audit Trail before go-live.
      3. Field history records consume data storage. For high-volume objects like Gift Transaction, confirm your org has adequate storage headroom before enabling broad tracking.

   2. **Identify the objects and fields your organization needs to audit**

      Use the table below as a starting point. Review it with your development director, finance lead, and any audit/compliance stakeholders before install. The right fields vary by organization — this table reflects common nonprofit audit needs, not a mandatory configuration.

      | Object | Suggested fields to track | Why |
      |---|---|---|
      | **Gift Transaction** | Status, OriginalAmount, CurrentAmount, AcknowledgementStatus, PaymentMethod, DonorId, CampaignId | Core financial record — audit trail for amount changes, status transitions, and acknowledgement |
      | **Gift Commitment** | Status, RecurrenceType, ExpectedTotalCmtAmount | Track schedule changes and cancellations for recurring gift retention analysis |
      | **Gift Designation** | IsActive, IsDefault, FQS_Restriction_Type__c | Restriction type changes have accounting implications |
      | **Opportunity** | StageName, Amount, CloseDate, OwnerId, FQS_Solicitation_Date__c, FQS_Grant_Deadline__c | Major gift and grant cultivation pipeline tracking |
      | **Campaign** | Status, StartDate, EndDate, BudgetedCost, FQS_Campaign_Category__c | Campaign lifecycle and budget tracking |
      | **Account** | (see Stakeholder Management Quick Start) | Donor record changes — address, name, relationships |

   3. **Note the package's deployed state for each object**
      1. **Campaign** — the package deploys Campaign with `enableHistory: true`. History tracking is active on Campaign from the moment the package is installed; you only need to select which fields to track in the post-install step.
      2. **Opportunity** — the package deploys Opportunity with `enableHistory: false`. You must explicitly enable it in Setup after install.
      3. **Gift Transaction, Gift Commitment, Gift Designation, and all other Fundraising objects** — these are Salesforce-managed standard objects. Their history tracking settings are not controlled by this package and must be configured in the target org's Setup after install.

   Supporting documentation:

   * [Field History Tracking](https://help.salesforce.com/s/articleView?id=platform.tracking_field_history.htm&type=5)
   * [Salesforce Shield Field Audit Trail](https://help.salesforce.com/s/articleView?id=platform.field_audit_trail.htm&type=5)

7. **Enable Contacts to Multiple Accounts**
   1. From Setup, enter **Account Settings** in the Quick Find box, and then select **Account Settings**.

      Note: Only users with the Customize Application permission can view or edit Account Settings.

   2. Click **Edit**.
   3. Select **Allow users to relate a contact to multiple accounts** and click **Save**.
   4. When the Contacts to Multiple Accounts Settings section appears, review the default options and save your changes.

Supporting documentation:

<!-- TODO: replace placeholder links with the actual Salesforce Help articles once verified
* https://help.salesforce.com/s/articleView?id=sfdo.fundraising_enable_fundraising.htm&type=5
* https://help.salesforce.com/s/articleView?id=sfdo.fundraising_assign_fundraising_permission_sets.htm&type=5
* https://help.salesforce.com/s/articleView?id=sfdo.fundraising_enable_person_accounts_for_fundraising.htm&type=5
* https://help.salesforce.com/s/articleView?id=sfdo.fundraising_manage_constituent_addresses.htm&type=5
-->

### Installation

1. Install the unmanaged package
   1. Log in to your sandbox or scratch org.
   2. Choose the appropriate URL:
      1. For Sandboxes and Scratch Orgs: <!-- TODO: paste install URL once package is uploaded -->
         `https://test.salesforce.com/packaging/installPackage.apexp?p0=<PACKAGE_ID>`
      2. For Production Environments: <!-- TODO: paste install URL once package is uploaded -->
         `https://login.salesforce.com/packaging/installPackage.apexp?p0=<PACKAGE_ID>`
   3. Paste the URL into your browser navigation bar and press Enter.
   4. Select Installation Scope. Choose how to install the package:
      1. Recommended: **Install for Admins Only** — components are only accessible by users with the Administrator profile.
      2. Install for All Users — components are available to all users in your organization.
      3. Install for Specific Profiles — you can choose to install for particular profiles, giving you more granular control.
   5. Click **Install**.
   6. If the installation takes a while, you can click **Done** and the installation completes in the background. Check your email for confirmation that the installation was successful.

### Post-Install Setup and Configuration

**I. Enable Settings**

1. **Enable Field History Tracking**

   Complete the fields you identified in the pre-install planning step (Before You Install, step 6) for each object. The steps below cover Campaign (package-deployed with history enabled but no fields selected), Opportunity (package-deployed with history disabled), and the Salesforce-managed Fundraising objects.

   1. **Configure field history tracking on Campaign**
      1. From **Setup**, click the **Object Manager** tab.
      2. Click the object name **Campaign**, then select **Fields & Relationships**.
      3. Click **Set History Tracking**.
      4. **Enable Campaign History** is already checked (the package enables it). Select the checkboxes next to the fields you want to track (e.g., Status, StartDate, EndDate, BudgetedCost, FQS\_Campaign\_Category\_\_c).
      5. Click **Save**.

   2. **Enable field history tracking on Opportunity**
      1. From **Setup**, click the **Object Manager** tab.
      2. Click the object name **Opportunity**, then select **Fields & Relationships**.
      3. Click **Set History Tracking**.
      4. Check **Enable Opportunity History**.
      5. Select the checkboxes next to the fields you want to track (e.g., StageName, Amount, CloseDate, OwnerId, FQS\_Solicitation\_Date\_\_c, FQS\_Grant\_Deadline\_\_c).
      6. Click **Save**.

   3. **Enable field history tracking on Gift Transaction**
      1. From **Setup**, click the **Object Manager** tab.
      2. Search for and click **Gift Transaction**, then select **Fields & Relationships**.
      3. Click **Set History Tracking**.
      4. Check **Enable Gift Transaction History**.
      5. Select the checkboxes next to the fields you want to track. Recommended starting fields: Status, OriginalAmount, CurrentAmount, AcknowledgementStatus, PaymentMethod, DonorId, CampaignId.
      6. Click **Save**.

   4. **Enable field history tracking on Gift Commitment**
      1. From **Setup**, click the **Object Manager** tab.
      2. Search for and click **Gift Commitment**, then select **Fields & Relationships**.
      3. Click **Set History Tracking**.
      4. Check **Enable Gift Commitment History**.
      5. Select the checkboxes next to the fields you want to track. Recommended starting fields: Status, RecurrenceType, ExpectedTotalCmtAmount.
      6. Click **Save**.

   5. **Enable field history tracking on Gift Designation**
      1. From **Setup**, click the **Object Manager** tab.
      2. Search for and click **Gift Designation**, then select **Fields & Relationships**.
      3. Click **Set History Tracking**.
      4. Check **Enable Gift Designation History**.
      5. Select the checkboxes next to the fields you want to track. Recommended starting fields: IsActive, IsDefault, FQS\_Restriction\_Type\_\_c.
      6. Click **Save**.

   *Notice: You can enable history tracking on other Fundraising objects (Gift Commitment Schedule, Gift Refund, Gift Transaction Designation, Gift Soft Credit, etc.) using the same steps. Prioritize the objects your finance and development teams actually query for audits — enabling tracking on every object and field is rarely necessary and consumes storage.*

   Supporting documentation:

   * [Field History Tracking](https://help.salesforce.com/s/articleView?id=platform.tracking_field_history.htm&type=5)

2. **Create and Configure an Org-Wide Email Address for Donor Acknowledgements**

   The Gift Acknowledgement flow sends automated emails to donors on behalf of your organization. By default, Salesforce sends automated emails from the address of the running user or the Default Workflow User, which is usually an internal admin address that donors should never see. Setting up a dedicated org-wide email address (e.g., `acknowledgements@yourorg.org`) gives donors a recognizable, reply-able sender and ensures acknowledgement emails do not appear to come from a staff member's personal account.

   *Before you start: Review [Considerations for Using Organization-Wide Email Addresses](https://help.salesforce.com/s/articleView?id=sales.emailadmin_orgwide_addresses_considerations.htm&type=5) — there are limits on the number of org-wide addresses you can create and important notes about how they interact with features like Email-to-Case.*

   1. **Create the org-wide email address**
      1. From **Setup**, in the **Quick Find** box, enter **Organization-Wide Addresses**, and then select **Organization-Wide Addresses**.
      2. Click **Add**.
      3. Enter the **Display Name** (e.g., *Your Organization Donor Acknowledgements*) and **Email Address** (e.g., `acknowledgements@yourorg.org`). Use an address your organization owns and can receive email on — Salesforce will send a verification email to it.
      4. For **Purpose**, select **User Selectable** so that users can choose this address when sending emails manually, in addition to its use by automated flows.
      5. For profile access, select **Allow All Profiles to Use this From Address** unless your org has a reason to restrict it to specific profiles.

         *Notice: If this org-wide address is also used for Email-to-Case, enabling Allow All Profiles can override Email-to-Case sender restrictions. If you use Email-to-Case, review the considerations doc linked above before enabling this setting.*

      6. Click **Save**. Salesforce sends a verification email to the address you entered.

   2. **Verify the email address**
      1. Open the inbox for the email address you entered.
      2. Click the verification link in the email from Salesforce.
      3. Return to **Organization-Wide Addresses** in Setup and confirm the address shows a **Verified** status before continuing.

   3. **Grant permission set access to the address** (optional but recommended)
      1. From **Setup**, in the **Quick Find** box, enter **Permission Sets**, and then select **Permission Sets**.
      2. Click the **FQS Custom Fields** permission set (or the permission set used by your gift officers and development staff).
      3. Select **Organization-Wide Email Address Access**.
      4. Click **Edit**.
      5. Move the acknowledgements address from **Available Organization-Wide Email Addresses** to **Enabled Organization-Wide Email Addresses**.
      6. Click **Save**.

   4. **Set the address as the Automated Process User email**
      1. From **Setup**, in the **Quick Find** box, enter **Process Automation Settings**, and then select **Process Automation Settings**.
      2. In the **Automated Process User Email Address** field, enter the org-wide email address you just created and verified (e.g., `acknowledgements@yourorg.org`).
      3. Click **Save**.

      This ensures that when the Gift Acknowledgement flow (and any other automated flow) sends an email using the Automated Process User context, the email appears to come from your donor-facing acknowledgements address rather than an internal system address.

   Supporting documentation:

   * [Considerations for Using Organization-Wide Email Addresses](https://help.salesforce.com/s/articleView?id=sales.emailadmin_orgwide_addresses_considerations.htm&type=5)
   * [Set Up Organization-Wide Email Addresses](https://help.salesforce.com/s/articleView?id=sf.emailadmin_orgwide_addresses_overview.htm&type=5)
   * [Process Automation Settings](https://help.salesforce.com/s/articleView?id=platform.customize_wf.htm&type=5)

**VII. Revisit Fundraising Settings and Configure Outreach Source Code**

Three items were intentionally left at their pre-install defaults during Before You Install step 3 (Fundraising Settings) because they depend on assets that only exist after the package is installed — the FQS Duplicate Rules for Donor Matching, a custom donor-matching external-ID field for Gift Entry, and the Outreach Source Code mappings which need the FQS-installed Platform picklist and Campaign Short Name field. Complete all three now in the same Fundraising Settings visit so you don't return to this screen later.

1. **Revisit Donor Matching Method in Fundraising Settings**

   During pre-install, **Donor Matching Method** was set to **No Matching** because the FQS Duplicate Rules had not yet been deployed. With the package now installed, flip it to **Duplicate Management Rules** so that donor lookups performed by the Business Process API check against `FQS_Contact_Dupe` and the `FQS_Account_*_Dupe` rules before creating a new record.

   1. From **Setup**, in the **Quick Find** box, enter **Fundraising**, and select **Fundraising Settings**.
   2. In the **Donor Matching** section, change **Donor Matching Method** to **Duplicate Management Rules**.
   3. Click **Save**.
   4. Verify the FQS Duplicate Rules are active in **Setup → Duplicate Rules** — `FQS_Contact_Dupe`, `FQS_Account_Organization_Dupe`, and `FQS_Account_Person_Dupe` should all show as **Active**. If any are inactive, activate them before continuing.

2. **Revisit Gift Entry External ID in Fundraising Settings**

   During pre-install, **Gift Entry — External ID** was left blank because FQS does not ship a donor-matching external-ID field. Revisit this setting only if your organization has introduced (or plans to introduce) a custom external-ID field on Account/Contact that donation-form tools, migration jobs, or ongoing integrations will populate for donor-matching purposes. If you have one:

   1. From **Setup**, in the **Quick Find** box, enter **Fundraising**, and select **Fundraising Settings**.
   2. In the **Gift Entry** section, set the **External ID** field to your custom donor-matching field.
   3. Click **Save**.

   If your org does not have such a field, leave this setting blank and skip to step 3.

3. **Configure Outreach Source Code**

   Outreach Source Code (OSC) setup has two halves: (a) the FQS-installed automation that creates a placeholder OSC on every Tactical campaign so the record is waiting for the user, and (b) the Salesforce-native UTM parameter mapping and Code Formula that populate the `SourceCode` field. Complete both before running FQS Campaign Hierarchy Setup for the first time — placeholder-OSC creation depends on the platform back-filling `SourceCode` at save, so the Code Formula must be configured first.

FQS ships with **automatic placeholder Outreach Source Code creation** for every Tactical (Level 3+) campaign. One placeholder OSC named **Create First OSC** is auto-created per tactical so the record is ready and waiting for the user — they fill in **Source Code** via the Generate Source Code quick action on the OSC record page, then rename. Users are expected to add additional OSCs for each channel variant (a second OSC for social paid, a third for direct mail, etc.).

The auto-creation runs in two paths, both routed through the same native record-triggered flow (`FQS_Campaign_Create_First_OSC`) — no Apex involved in the OSC create step:

1. **During FQS Campaign Hierarchy Setup** — after the hierarchy builder inserts the Level 3 tacticals, it flips **Create First Outreach Source Code** to true on each Ask. The record-triggered flow fires on the update and creates the placeholder OSC. The Final screen shows the count.
2. **Manually per-campaign** — check the **Create First Outreach Source Code** checkbox on any Tactical campaign; the record-triggered flow creates the placeholder. Idempotent (flow Gets the placeholder by External_Id__c first and short-circuits if it already exists) — safe to re-check if the earlier OSC was deleted. The checkbox stays checked afterward as a persistent audit flag.

The placeholder OSC is populated as follows:

| OSC field | Value |
|---|---|
| `Name` | `Create First OSC` — CTA placeholder; rename after populating Source Code |
| `SourceCode` | *(blank)* — populated by the **Generate Source Code** quick action on the OSC record page using the Setup-configured Code Formula (see the Code Formula subsection below) |
| `CampaignId` | Parent tactical campaign |
| `Status` | `Active` when `Campaign.IsActive = true`, else `Inactive` |
| `UsageType` | `Fundraising` |
| `MessageChannel` | Pre-seeded from `FQS_Campaign_Category__c` as a starting point — see mapping below; user can change before generating the Source Code |
| `FQS_Platform__c` | Pre-seeded from `FQS_Campaign_Category__c` as a starting point — see mapping below; user can change before generating the Source Code |
| `FQS_Message_Channel_Segment__c` | Auto-derived formula field (Organic / Paid Digital / Owned or Acquired Lists) |
| `External_Id__c` | `FQS-OSC-{CampaignId15}-DEFAULT` — unique key that guarantees one placeholder per campaign |

**Category → Channel/Platform mapping**

| Campaign Category | MessageChannel | Platform |
|---|---|---|
| Annual Giving | Direct Mail | Direct Mail House |
| Planned Giving | Direct Mail | Direct Mail House |
| Grants | Direct Mail | Direct Mail House |
| Events | Email | Other Email Platform |
| Corporate Match | Email | Other Email Platform |
| In-Kind | Email | Other Email Platform |
| Major Gifts | Physical | *(blank)* |
| *(blank or other)* | Email | Other Email Platform |

These pre-seeds are a low-friction starting point. Users edit Channel/Platform on the placeholder as needed, then click **Generate Source Code** so the Setup-configured Code Formula populates `SourceCode`, and rename off "Create First OSC" to the intended tactic label. Add additional OSCs for each channel variant on the campaign the same way.

---

Beyond the FQS defaults, Salesforce Fundraising can automatically generate a standardized `SourceCode` value on each Outreach Source Code record based on a formula you define. This keeps your source codes consistent and machine-readable without relying on gift officers to type them manually.

**Why FQS ships a custom `Platform` picklist.** The Outreach Source Code standard schema exposes `MessageChannelPlatform` as a **free-text** field, which produces the classic attribution problem: `Instagram`, `instagram`, `IG`, and `insta` all become distinct values, and rollups fragment. FQS introduces a custom picklist field, **Platform** (`FQS_Platform__c`), that constrains input to a governed set of options (Facebook, Instagram, Google Ads, Mailchimp, Direct Mail House, etc.). Users pick from the picklist, which keeps channel-level attribution clean and rollup-friendly on the OSC record even though it is not used in the SourceCode string itself.

The FQS convention maps UTM parameters to the Outreach Source Code data model as follows, using a **campaign-anchored** Code Formula: `{Campaign.FQS_Short_Name__c}`

| UTM Parameter | Maps to object | Maps to field | Why |
|---|---|---|---|
| UTM Source | Outreach Source Code | `FQS_Platform__c` (Platform) | The specific platform or source within a channel (e.g., `Instagram`, `Mailchimp`, `Google Ads`), governed as a picklist for rollup consistency |
| UTM Medium | Outreach Source Code | `MessageChannel` (Message Channel) | The delivery channel type (Email, Direct Mail, Social Paid, etc.) |
| UTM Campaign | Campaign | `FQS_Short_Name__c` (Short Name) | A short, URL-safe campaign identifier (e.g., `fy26-yearend`) rather than the full campaign name |

**Steps**

1. From **Setup**, in the **Quick Find** box, enter **Fundraising**, and then select **Outreach Source Codes**.

2. **Set the UTM parameter mappings**
   1. For **UTM Source**, set **Custom Object** to **Outreach Source Code** and **Custom Field** to **Platform** (`FQS_Platform__c`).
   2. For **UTM Medium**, set **Custom Object** to **Outreach Source Code** and **Custom Field** to **Message Channel** (`MessageChannel`).
   3. For **UTM Campaign**, set **Custom Object** to **Campaign** and **Custom Field** to **Short Name** (`FQS_Short_Name__c`).

3. **Turn on Outreach Source Code Generation**
   1. Toggle **Outreach Source Code Generation** to on.
   2. The **Code Formula Structure** section opens.

4. **Build the code generation formula**
   1. Using the reference fields, functions, and operators in the formula builder, construct the following formula:
      ```
      {Campaign.FQS_Short_Name__c}
      ```
   2. Add the token by selecting it from the reference fields panel rather than typing it manually — this ensures the syntax is valid.
   3. Salesforce will **append random characters to the SourceCode automatically to guarantee uniqueness** whenever the Code Formula alone doesn't resolve to a distinct value (per the platform's own note: *"Random numbers are appended to the source code to ensure uniqueness if a code structure is not set or the Reference field is not referable."*). Because every Outreach Source Code under a single campaign shares the same Short Name, this uniqueness suffix is what makes the code distinct across the campaign's OSCs — the FQS convention leans on that behavior instead of hand-composing a multi-segment formula.

5. **Validate and save**
   1. Click **Validate Syntax** to confirm the formula is valid. Fix any errors before proceeding.
   2. Click **Save**.

Once saved, Salesforce will auto-populate the `SourceCode` field on new Outreach Source Code records with `{Campaign.FQS_Short_Name__c}` plus the platform-appended uniqueness suffix. For example, three OSCs on a campaign with Short Name `fy26-yearend` might generate `fy26-yearend`, `fy26-yearend-a7f2`, and `fy26-yearend-9x31` — the campaign anchor is human-legible while Salesforce guarantees each row's SourceCode is unique.

*Notice: The formula acts on the value of `FQS_Short_Name__c` at the time the Outreach Source Code record is saved. If Campaign Short Name is blank, only the auto-appended random suffix will populate the SourceCode. Ensure the Campaign Short Name is populated before creating Outreach Source Codes against a campaign.*

**Graduating to a richer SourceCode.** If your team decides to encode more attribution directly in the SourceCode string rather than relying on the platform's uniqueness suffix, consider **replacing the campaign-anchored formula above with a multi-segment Code Formula** that composes several fields. You have three field families to choose between as building blocks:

- The FQS custom **Platform** picklist (`FQS_Platform__c`) — governed values, best for rollup consistency
- The standard **Message Channel Platform** (`MessageChannelPlatform`) free-text field — flexible catch-all
- The standard **Message Channel Account** field — when attribution needs to tie to a specific account/handle (e.g., a specific Instagram business account or ad account) rather than the platform in the abstract

Mix and match those inputs in your Code Formula Structure to match how your organization actually reports on channel performance (for example: `{FQS_Platform__c} + "-" + {MessageChannel} + "-" + {Campaign.FQS_Short_Name__c}`).

Supporting documentation:

* [Set Up Outreach Source Codes](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_set_up_outreach_source_codes.htm&type=5)

---

**II. Configure App Access**

Assign the Fundraising Quick Start Lightning app to the right profiles before any downstream configuration. The remaining post-install steps assume you are working inside the FQS app — its navigation, home page walkthrough (§XII), and shipped list views are the intended context for every setup task that follows.

1. **Change Access to Lightning Apps**
   1. From Setup, in the Quick Find box, enter 'App Manager', and then select **App Manager**.
   2. Click the icon on the **Fundraising Quick Start** app's row, and select **Edit**.
   3. Under 'App Settings', click on **User Profiles**.
   4. Select the appropriate Profiles in the **Available Profiles** column and move to **Selected Profiles**.
   5. Click **Save**.

2. **Navigate to Fundraising Quick Start**
   1. Click the **App Launcher** icon (nine dots) on the far left of the top navigation bar.
   2. Select **Fundraising Quick Start**. If unavailable use the **Search apps and items** box.

**III. Set Up the Automation App and Create a Flows List View**

The **Automation** Lightning app gives admins a central place to monitor, activate, and deactivate flows without navigating through Setup. Creating a saved list view scoped to FQS and Nonprofit Cloud Fundraising flows makes it easy to confirm that the right flows are active and to spot any that failed or were inadvertently deactivated.

1. **Open the Automation app**
   1. Click the **App Launcher** icon (nine dots) in the top navigation bar.
   2. Search for **Automation** and select the **Automation** app.
   3. If the app is not visible, it may not be enabled for your profile. From **Setup**, in the **Quick Find** box, enter **App Manager**, select **App Manager**, find **Automation** in the list, click the row action, and select **Edit** to assign it to the appropriate profiles.

2. **Create a list view for FQS and Nonprofit Cloud flows**
   1. In the Automation app, ensure you are on the **Flows** tab.
   2. Click the list view selector (the funnel icon or the current list view name near the top left) and select **New**.
   3. Enter a **List Name** of `FQS and NPC Flows` (or your preferred label).
   4. Set visibility to **Visible to all users** so other admins can use it.
   5. Click **Save**.

3. **Add filter 1 — FQS flows by API name**
   1. In the list view, click the **Filters** icon (funnel).
   2. Click **Add Filter**.
   3. Set **Field** to **API Name**.
   4. Set **Operator** to **starts with**.
   5. Set **Value** to `FQS`.
   6. Click **Done**.

4. **Add filter 2 — Nonprofit Cloud platform flows by namespace**
   1. Click **Add Filter** again.
   2. Set **Field** to **Flow Namespace**.
   3. Set **Operator** to **contains**.
   4. Set **Value** to `frops_flow`.
   5. Click **Done**.

5. **Set the filter logic to OR**
   1. Click **Filter Logic**.
   2. Change the logic to `1 OR 2`.
   3. Click **Done**.
   4. Click **Save**.

   The list view now shows all flows whose API name starts with `FQS` (the accelerator's flows) **or** whose namespace contains `frops_flow` (the Nonprofit Cloud Fundraising platform flows), giving you a single view of the full automation surface for this accelerator.

6. **Review flow statuses**
   1. Scan the list for any flows with a status of **Inactive** or **Invalid Draft**.
   2. The **FQS Gift Acknowledgement** flow will appear **Inactive** here — this is expected. Activate it only after completing section VIII (Review and Customize Donor Tiers) and section IX (Review and Activate the Gift Acknowledgement Flow).
   3. All other FQS flows should be **Active** after package installation. If any show as Inactive or Invalid Draft, investigate before going live.

**IV. Assign Permission Sets**

1. **Assign the FQS Custom Fields Permission Set**
   1. From Setup, in the Quick Find box, enter 'Permission Sets', and then select **Permission Sets**.
   2. Click the permission set **FQS Custom Fields** in the list view.
   3. To assign your user:
      1. Click **Manage Assignments**.
      2. Click **Add Assignments**.
      3. Select each user to whom you want to assign the set, and then click **Next**.
      4. *Optional:* Select an expiration date for the user assignment to expire.
      5. Click **Assign**.
      6. Click **Done**.

2. **Assign the FQS Campaign Fields Permission Set**

   The **FQS Campaign Fields** permission set grants read/edit access to the standard Campaign fields used by the FQS Campaign Hierarchy Setup flow and by day-to-day Campaign maintenance — StartDate, EndDate, ParentId, Status, IsActive, ExpectedRevenue, BudgetedCost, ActualCost, Description, and the standard Campaign rollup counters. Assign it to any staff who will run FQS Campaign Hierarchy Setup or who will edit Campaign records directly.

   1. From Setup, in the Quick Find box, enter **Permission Sets**, and then select **Permission Sets**.
   2. Click the permission set **FQS Campaign Fields** in the list view.
   3. To assign your user:
      1. Click **Manage Assignments**.
      2. Click **Add Assignments**.
      3. Select each user to whom you want to assign the set, and then click **Next**.
      4. *Optional:* Select an expiration date for the user assignment to expire.
      5. Click **Assign**.
      6. Click **Done**.

3. **Assign the Fundraising CSV Advanced Data Import Permission Set**

   The **Fundraising CSV Advanced Data Import** permission set grants access to Salesforce's CSV-based gift import tool for Nonprofit Cloud Fundraising. Assign it to staff who will be responsible for bulk-loading or migrating gift data — typically a data manager, gift entry lead, or system administrator. Not all gift-entry staff need this permission; only those who will perform CSV imports.

   1. From Setup, in the Quick Find box, enter **Permission Sets**, and then select **Permission Sets**.
   2. Click the permission set **Fundraising CSV Advanced Data Import** in the list view.
   3. To assign your user:
      1. Click **Manage Assignments**.
      2. Click **Add Assignments**.
      3. Select each user to whom you want to assign the set, and then click **Next**.
      4. *Optional:* Select an expiration date for the user assignment to expire.
      5. Click **Assign**.
      6. Click **Done**.

4. **Assign the FQS Record Type Access Permission Set**

   The **FQS Record Type Access** permission set grants visibility on three record types the accelerator relies on: `Campaign.FQS_Fundraising` (the fundraising campaign record type used throughout FQS), `Opportunity.Grant`, and `Opportunity.Major_Gift`. Assign it to any user who will create or edit Campaigns or Opportunities — without it, users see only the record types their Profile grants directly and the FQS flows and dynamic pages that key off these record types produce ambiguous "Which Record Type?" dialogs or no options at all.

   1. From Setup, in the Quick Find box, enter **Permission Sets**, and then select **Permission Sets**.
   2. Click the permission set **FQS Record Type Access** in the list view.
   3. To assign your user:
      1. Click **Manage Assignments**.
      2. Click **Add Assignments**.
      3. Select each user, and then click **Next**.
      4. *Optional:* Select an expiration date.
      5. Click **Assign**.
      6. Click **Done**.

5. **Assign the FQS Person Account Fields Permission Set** (only if Person Accounts is enabled)

   The **FQS Person Account Fields** permission set grants read/edit access to the Person-Account-specific standard fields on Account (birthdate, salutation, department, opt-out flags, and related name/title fields). The permset intentionally does **not** grant Person Account record type visibility — this mirrors the pattern used by the Stakeholder Management Quick Start and avoids a hard install-time dependency on Person Accounts being enabled. Grant record type access manually as a follow-up step below. Skip this entire step if your org has not enabled Person Accounts.

   1. From Setup, in the Quick Find box, enter **Permission Sets**, and then select **Permission Sets**.
   2. Click the permission set **FQS Person Account Fields** in the list view.
   3. Assign users:
      1. Click **Manage Assignments**.
      2. Click **Add Assignments**.
      3. Select each user, and then click **Next**.
      4. *Optional:* Select an expiration date.
      5. Click **Assign**.
      6. Click **Done**.
   4. Grant Person Account record type visibility on the permset:
      1. Return to the permission set detail page (**Setup → Permission Sets → FQS Person Account Fields**).
      2. Click **Object Settings**.
      3. Click **Accounts** in the Object Name list.
      4. Click **Edit**.
      5. Check the **Assigned Record Types** checkbox next to the Person Account record type. If you followed the recommendation in Before You Install step 5, this record type is labeled **Individual**; if you chose a different label, select the one you chose.
      6. Click **Save**.

6. **Assign Permission Sets for System Integration Users**

   The accelerator ships four permission sets meant for system integration users — the accounts that back data-loading and data-migration jobs, ongoing integrations with donation-form tools (Classy, GiveLively, Every.org, custom Experience Cloud portals), and any other automated pipe writing into the fundraising data model. Assign these directly to the specific integration users or integration-user profiles that need them; do not roll them into the permission set groups used for day-to-day human staff.

   * **FQS Rollup DPE Read** — grants read access on the standard fields the three shipped Fundraising Data Processing Engine (DPE) definitions read at runtime (GiftCommitment, GiftTransaction, GiftDesignation, GiftSoftCredit, GiftTransactionDesignation, GiftCmtChangeAttrLog, OutreachSummary, OutreachSourceCode, PartyRelationshipGroup). Assign to the built-in **Integration User** (Profile: Analytics Cloud Integration User; Username pattern: `integration@<orgid>.com`). Fundraising Cloud's Analytics Cloud Integration User profile grants object-level access to these objects out of the box but does **not** ship field-level access to standard fields; without this permission set the DPE save fails with errors such as *"the integration user with the Analytics Cloud Integration User profile doesn't have access to the ScheduleType field of GiftCommitment"*. Verify by opening any of the three DPE definitions (**Setup → Data Processing Engine**) and clicking **Save** — it should now save without field-access errors.

   * **FQS Bypass Automation** — grants the `FQS_Bypass_Automation` custom permission, which short-circuits the FQS record-triggered flows that maintain derived state (currently the three flows that recalc `GiftCommitment.FulfillmentType`). Assign to migration runners, Data Loader operators, mass-update jobs, and any ongoing integration whose upstream system is authoritative for the fields these flows recalculate. After a bulk load, run `scripts/apex/fqs-recalc-gc-fulfillmenttype.apex` to reconcile `FulfillmentType` across affected commitments. See Post-Install Considerations §4 for the full pattern.

   * **FQS Naming Opt Out** — grants the `FQS_Skip_Record_Naming` custom permission plus edit FLS on `FQS_Skip_Naming__c` for GiftCommitment, GiftTransaction, and Opportunity. Assign to migration users and to any ongoing integration whose upstream system owns the record Name — this prevents FQS's auto-naming flows from overwriting names coming from that system.

   * **FQS Email Template Builder Permission** — grants the `AccessContentBuilder` user permission, needed to edit templates in the Lightning Email Template Builder. Assign only to admins who want to rebuild the shipped Classic email templates in the drag-and-drop Builder (see Post-Install Considerations §10). Day-to-day use of the FQS Gift Acknowledgement and Stewardship flows does not require this permset — the flows send with the Classic templates as-is.

   To assign any of these:
   1. From Setup, in the Quick Find box, enter **Users** (for named users) or **Permission Sets** (for direct permset assignment).
   2. Locate the integration user or the permission set.
   3. Add the permission set to the user's **Permission Set Assignments** and click **Save**.

**X. Set Up Queues**

FQS ships four queues (`FQS_Executive_Fundraising_Tasks`, `FQS_Gift_Processing_Tasks`, `FQS_Major_Donor_Tasks`, `FQS_Stewardship_Tasks`) and expects a fifth (`FQS_Gift_Acknowledgements`) to exist before the Gift Acknowledgement flow (§IX) is activated. The Home Page walkthrough (§XII, accordion item 8 — *Review Automation and Queue Membership*) reinforces this — end users following the accordion top-to-bottom will only see accurate queue guidance if membership is already in place.

**Queues shipped by the package** — each supports both **Task** and **ActionPlan** sObjects:

| Queue | Purpose |
| --- | --- |
| `FQS_Executive_Fundraising_Tasks` | Executive-level tasks — used by Action Plans that need executive attention. |
| `FQS_Gift_Processing_Tasks` | Gift entry, acknowledgement, and tax-receipting tasks created by the Moves Management and Stewardship Action Plans. |
| `FQS_Major_Donor_Tasks` | Research and proposal-creation tasks for the Moves Management Action Plan. |
| `FQS_Stewardship_Tasks` | Cultivation tasks created by the Stewardship Action Plan. |

**Queue you must create manually** — the Gift Acknowledgement flow assigns fallback Tasks to `FQS_Gift_Acknowledgements` when a donor tier is routed to Exclude All / Exclude Lifetime. This queue is not shipped in the package because Task queue metadata for the standard Task object requires org-specific member assignments:

1. From Setup, in the Quick Find box, enter **Queues**, and click **New**.
2. **Label:** `FQS Gift Acknowledgements`. **Name:** `FQS_Gift_Acknowledgements`.
3. **Queue Email:** the shared inbox for gift-acknowledgement escalations (typically the same acknowledgements address used in the org-wide email addresses set up in §I).
4. **Supported Objects:** add **Task**.
5. **Queue Members:** add the users, roles, or public groups who should receive escalated acknowledgement tasks. Include at least one active user, or Tasks assigned to this queue will be invisible to work-lists.
6. Click **Save**.

**Add members to the four shipped queues:**

1. From Setup, in the Quick Find box, enter **Queues**.
2. For each of the four shipped queues, click the queue Label to open it.
3. Click **Edit**.
4. Add the appropriate users, roles, or public groups to **Queue Members** — matching your org's development-team structure. See Post-Install Considerations §2 (*Review Profiles and Permission Sets*) for guidance on segregating duties.
5. Click **Save**.

Supporting documentation:

* [Create and Manage Queues](https://help.salesforce.com/s/articleView?id=platform.setting_up_queues.htm&type=5)

**V. Configure Gift Transaction and Gift Commitment Access**

1. **Assign FQS Dynamic Lightning Record Pages and Layouts to the Right Profiles**

   The accelerator ships dynamic Lightning record pages (flexipages) tuned for fundraising workflows, but standard objects still rely on classic page layouts to control some behavior on those Lightning pages (related list membership, mobile card visibility, and profile-level field defaults). Assign both the flexipages and the shipped classic page layouts to the appropriate profiles for your org. The right set of profiles is org-specific — pick the profiles that reflect who will do gift-entry and development work in your organization.

   The record pages and layouts that most commonly need explicit profile assignment:

   * **Opportunity** — `FQS_Opportunity_Record_Page` and **FQS Opportunity Layout**.
   * **Campaign** — `FQS_Campaign_Record_Page` and **FQS Campaign Layout**.
   * **Person Account** — **FQS Person Account Layout** (if your org uses Person Accounts).
   * **Account** — `FQS_Account_Record_Page` and **FQS Account Layout**.

   For each record page:
   1. From **Setup**, in the **Quick Find** box, enter **Lightning App Builder**, and then select **Lightning App Builder**.
   2. Open the flexipage from the list.
   3. Click **Activation**, then **Assign as Org Default** or **Assign as App Default** and pick the app(s).
   4. Under **Assign to profiles**, select each profile that should see this record page and click **Next**, then **Save**.

   For each classic page layout, assign it in **Setup → Object Manager → [object] → Page Layouts → Page Layout Assignment**.

   Supporting documentation:

   * [Assign a Lightning Record Page](https://help.salesforce.com/s/articleView?id=platform.lightning_app_builder_customize_lex_pages_assign.htm&type=5)

2. **Configure Gift Transaction**

   Complete the following edits in a single **Setup → Object Manager → Gift Transaction** visit. Gift Transaction is a Nonprofit Cloud–owned standard object, so none of these edits ship in the unmanaged package — apply each in the target org after install.

   1. **Remove `New` from the list view button layout.** Gift Transactions are meant to be created through one of three supported paths: the **Gift Entry Grid** (batch entry for development staff), an **integration using the Business Process API** (donation form tools, integration hubs, lockbox importers), or the **guided gift-entry flows** shipped with FQS. Direct list-view creation bypasses the validation, soft-credit / designation defaulting, and acknowledgement-status wiring these paths apply.
      1. In Object Manager for Gift Transaction, select **Search Layouts**.
      2. Locate the row named **List View** and click **Edit**.
      3. Move **New** from the **Selected Buttons** column to the **Available Buttons** column.
      4. Click **Save**.

      *Notice: Removing New from the list view button layout removes it from the list-view page, but does not prevent Apex, integration, or flow creation of Gift Transaction records. That is intended — the three supported creation paths all bypass the UI list view and continue to work.*

   2. **Configure Search Layouts.** Search Layouts control which fields appear on the object's Tab list view, search results, and lookup dialogs. Apply the following field selections so fundraising staff can identify a gift at a glance.

      Recommended fields on all four search layouts (**Default Layout** / Tab, **Search Results**, **Lookup Dialogs**, **Lookup Phone Dialogs**):

      * Donor
      * Transaction Date
      * Transaction Due Date
      * Current Amount
      * Status
      * FQS Gift Transaction Category

      1. Still in **Search Layouts** for Gift Transaction, click **Edit** on **Default Layout**.
      2. Move the six fields above into the **Selected Fields** column and click **Save**.
      3. Repeat for **Search Results**, **Lookup Dialogs**, and **Lookup Phone Dialogs**.

   3. **Add the leaf-Campaign lookup filter to `Campaign`.** The filter steers users to attribute each gift to a level-3 (ask) Campaign — the concrete solicitation — rather than a level-1 rollup or level-2 strategy. Ask-level attribution keeps performance reports honest; rollup-level attribution hides the ask from the numbers you were trying to measure. The filter uses `FQS_Hierarchy_Depth__c` on Campaign — a formula field the package installs (1 = top rollup, 2 = strategy, 3 = ask, up to 5 levels). It ships as **Optional** so users can override for exceptions.
      1. In Object Manager for Gift Transaction, select **Fields & Relationships**.
      2. Click the field **Campaign**.
      3. Scroll down to **Lookup Filter** and click **Edit**.
      4. Select **Show only records that match the filter criteria (Optional)**.
      5. Add the following filter criterion:
         * **Field:** Campaign: Hierarchy Depth
         * **Operator:** greater or equal
         * **Value:** 3
      6. In the **Info Message** field, enter: *FQS reporting expects gifts to be attributed to a level-3 (ask) campaign or deeper. Higher levels are rollups.*
      7. In the **Error Message** field, enter: *Pick a leaf-level Campaign (the actual ask). Rollups and strategies are for reporting only — attributing a gift there hides it from ask-level performance reports.*
      8. Confirm **Filter Type** is **Optional**.
      9. Click **Save**.

   4. **Add help text and description to `Current Amount`.** `CurrentAmount` is not writable via API or Apex — attempting to set it returns `INVALID_FIELD_FOR_INSERT_UPDATE`. It equals `OriginalAmount` until a Gift Refund is posted, at which point the platform recomputes it. The help text prevents a user from trying to "correct" an amount by editing this field.
      1. In Object Manager for Gift Transaction → **Fields & Relationships**, click the field **Current Amount**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *Set automatically. The gift amount remaining after any refunds or adjustments. Equals the Original Amount unless a Gift Refund has been posted.*
      4. In the **Description** field, enter: *Not writable via API or Apex — attempting to set returns `INVALID_FIELD_FOR_INSERT_UPDATE`. To reduce, insert a GiftRefund child instead of mutating this field.*
      5. Click **Save**.

   5. **Add help text and description to `Transaction Date`.** FQS treats this as the canonical "when did this gift happen" date — the date the gift is fully in the org's hands and reconciled (check cleared, card settled, wire received, stock sold, in-kind item taken into custody). End users often default to entering the donor's mailing / signing / postmark date, which belongs on the separate `FQS_Donor_Tax_Date__c` field. FQS's cash-flow reporting, aging, and rollups all anchor to Transaction Date.
      1. In Object Manager for Gift Transaction → **Fields & Relationships**, click the field **Transaction Date**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *The date the donor made this gift — check date, credit-card charge date, or the date the wire hit. Required when Status is Paid or Fully Refunded.*
      4. In the **Description** field, enter: *For pledge payments, this is the payment date, not the pledge date (which lives on the parent commitment's `EffectiveStartDate`).*
      5. Click **Save**.

   6. **Add help text and description to `Transaction Due Date`.** `TransactionDueDate` is required on insert *even for gifts already in Paid status*. For outright gifts, it should equal `TransactionDate`; for pledge payments, it matches the parent `GiftCommitmentSchedule` installment row. Missing help text here is a common source of "why is the platform asking me for a due date on a paid gift" support tickets.
      1. In Object Manager for Gift Transaction → **Fields & Relationships**, click the field **Transaction Due Date**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *The date this gift was expected. For a one-time gift you're recording now, set the same date as Transaction Date. For a pledge or recurring payment, this matches the installment's scheduled due date.*
      4. In the **Description** field, enter: *Required on insert even for gifts in Paid status. For outright gifts, set equal to `TransactionDate`. For pledge payments, match the parent `GiftCommitmentSchedule` installment row.*
      5. Click **Save**.

   7. **Add help text and description to `Non-Tax Deductible Amount`.** `NonTaxDeductibleAmount` is the quid-pro-quo field — the value of any goods or services the donor received in exchange for the gift (event tickets, dinners, benefits). It is **not** auto-computed; when populated, the platform expects `TaxDeductionAmount = CurrentAmount − NonTaxDeductibleAmount`. Getting this wrong misstates the receiptable portion of the gift.
      1. In Object Manager for Gift Transaction → **Fields & Relationships**, click the field **Non-Tax Deductible Amount**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *The portion of this gift the donor cannot deduct — e.g., the fair-market value of event tickets, dinners, or benefits received in exchange for the gift.*
      4. In the **Description** field, enter: *Quid-pro-quo tracking. When populated, `TaxDeductionAmount` should equal `CurrentAmount − NonTaxDeductibleAmount`. Not auto-computed.*
      5. Click **Save**.

3. **Configure Gift Commitment**

   Complete the following edits in a single **Setup → Object Manager → Gift Commitment** visit. Same standard-field caveat as Gift Transaction — none of these edits ship in the unmanaged package.

   1. **Remove `New` from the list view button layout.** Same rationale as Gift Transaction: commitments are created through the Gift Entry Grid, the Business Process API, or the FQS guided flows, not through a list-view New button.
      1. In Object Manager for Gift Commitment, select **Search Layouts**.
      2. Locate the row named **List View** and click **Edit**.
      3. Move **New** from the **Selected Buttons** column to the **Available Buttons** column.
      4. Click **Save**.

   2. **Configure Search Layouts.** Recommended fields on both search layouts (**Default Layout** / Tab, **Search Results**):

      * Status
      * FQS Gift Commitment Category
      * Expected Total Commitment Amount
      * Next Transaction Date

      1. Still in **Search Layouts** for Gift Commitment, click **Edit** on **Default Layout**.
      2. Move the four fields above into the **Selected Fields** column and click **Save**.
      3. Repeat for **Search Results**.

   3. **Add the leaf-Campaign lookup filter to `Campaign`.** Same rationale and settings as Gift Transaction step 2.3.
      1. In Object Manager for Gift Commitment, select **Fields & Relationships**.
      2. Click the field **Campaign**.
      3. Scroll down to **Lookup Filter** and click **Edit**.
      4. Select **Show only records that match the filter criteria (Optional)**.
      5. Add the following filter criterion:
         * **Field:** Campaign: Hierarchy Depth
         * **Operator:** greater or equal
         * **Value:** 3
      6. In the **Info Message** field, enter: *FQS reporting expects commitments to be attributed to a level-3 (ask) campaign or deeper. Higher levels are rollups.*
      7. In the **Error Message** field, enter: *Pick a leaf-level Campaign (the actual ask). Rollups and strategies are for reporting only — attributing a commitment there hides it from ask-level performance reports.*
      8. Confirm **Filter Type** is **Optional**.
      9. Click **Save**.

   4. **Add help text to `Campaign`.** The lookup filter added in step 3 above restricts this picker to leaf-level (ask) campaigns, but the help text makes the "why" visible on the record page itself. Ask-level attribution keeps performance reporting honest.
      1. In Object Manager for Gift Commitment → **Fields & Relationships**, click the field **Campaign**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *The campaign this pledge or recurring commitment is attributed to. Pick a leaf-level ask campaign — rollups and strategy branches are for reporting only.*
      4. Click **Save**.

   5. **Add help text and description to `Formal Commitment Type`.** The picklist offers *Verbal* and *Written*; without help text, users routinely pick the wrong one for pledge documentation and downstream stewardship reporting suffers.
      1. In Object Manager for Gift Commitment → **Fields & Relationships**, click the field **Formal Commitment Type**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *How the donor made this commitment. Pick Written when you have a signed agreement or email; Verbal for a phone or in-person conversation.*
      4. In the **Description** field, enter: *Allowed values: Verbal, Written.*
      5. Click **Save**.

   6. **Add help text and description to `Fulfillment Type`.** *Unconditional* vs *Conditional* determines whether committed funds are usable on arrival or contingent on milestones (typical for grants). Reporting-only in FQS but distinguishes grant management flows from unconditional pledges.
      1. In Object Manager for Gift Commitment → **Fields & Relationships**, click the field **Fulfillment Type**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *Choose Unconditional when the committed funds are usable as soon as they arrive. Choose Conditional when the gift is contingent on specific milestones being met — typical for grants with reporting or programmatic conditions.*
      4. In the **Description** field, enter: *Restricted picklist. Legal values: Unconditional, Conditional. Reporting-only in FQS. Default: Unconditional.*
      5. Click **Save**.

   7. **Add help text and description to `Recurrence Type`.** *Fixed Length* vs *Open Ended* is the difference between a pledge (has an end) and a recurring gift (no end). The platform does **not** derive this from the child schedule — it has to be set explicitly on the parent commitment.
      1. In Object Manager for Gift Commitment → **Fields & Relationships**, click the field **Recurrence Type**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *Choose Fixed Length for pledges, grants, and scheduled gifts with a defined end date. Choose Open Ended for recurring gifts with no end date — the donor gives on a regular cadence until they cancel.*
      4. In the **Description** field, enter: *Restricted picklist. Legal values: Fixed Length, Open Ended. Set explicitly by the launcher / seed generator; the platform does not derive this from the child schedule. Default: Open Ended.*
      5. Click **Save**.

   8. **Add help text to `Schedule Type`.** For standard recurring gifts and pledges, leave blank — the platform sets it from the attached schedule. *Custom* is the escape hatch for irregular grant schedules (variable amounts, uneven spacing) that Apex has to create directly because Flow can't build them.
      1. In Object Manager for Gift Commitment → **Fields & Relationships**, click the field **Schedule Type**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *Leave blank for standard recurring gifts and pledges — the platform will fill this in from the schedule you attach. Set to Custom only when the schedule has irregular installment amounts or spacing (typical for grants).*
      4. Click **Save**.

   9. **Add help text to `Effective Start Date`.** End users often assume this is the date the first payment posts, when it is actually the date the donor formally committed (signed the pledge or grant letter). Those two dates can differ by weeks or months.
      1. In Object Manager for Gift Commitment → **Fields & Relationships**, click the field **Effective Start Date**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *The date the donor formally committed to this gift (signed the pledge or grant letter). This can be earlier than when the first payment arrives.*
      4. Click **Save**.

4. **Configure Campaign**

   Complete the following edit in a **Setup → Object Manager → Campaign** visit.

   1. **Configure Search Layouts.** Campaign is in the FQS Console app; apply the following field selections so the Campaign tab, search results, and lookup dialogs surface the fields fundraising staff need to identify the right campaign fast (particularly when picking one during gift entry).

      Recommended fields on **Default Layout** (Tab):

      * Campaign Name
      * FQS Campaign Category

      Recommended fields on **Search Results**:

      * Campaign Name
      * FQS Campaign Category
      * Status
      * Active
      * Start Date
      * End Date
      * Parent Campaign

      Recommended field on **Lookup Dialogs** and **Lookup Phone Dialogs**:

      * Campaign Name

      1. In Object Manager for Campaign, select **Search Layouts**.
      2. For each layout row above, click **Edit**, move the recommended fields into **Selected Fields**, and click **Save**.

5. **Configure Opportunity**

   Complete the following edits in a single **Setup → Object Manager → Opportunity** visit.

   1. **Configure Search Layouts.** Opportunity is in the FQS Console app; apply the following field selections so gift officers can find a cultivation record by donor + stage at a glance.

      Recommended fields on **Default Layout** (Tab):

      * Opportunity Name
      * Account Name
      * Stage
      * Amount
      * Close Date

      Recommended fields on **Search Results**:

      * Opportunity Name
      * Account Name
      * Stage
      * Amount
      * Close Date
      * Owner Alias

      Recommended fields on **Lookup Dialogs** and **Lookup Phone Dialogs**:

      * Opportunity Name
      * Account Name
      * Account Site

      1. In Object Manager for Opportunity, select **Search Layouts**.
      2. For each layout row above, click **Edit**, move the recommended fields into **Selected Fields**, and click **Save**.

   2. **Add help text and description to `Amount`.** On close-won, the FQS Opportunity launcher writes this into the resulting `GiftCommitment.ExpectedTotalCmtAmount` or `GiftTransaction.OriginalAmount`. The Opportunity here represents an expected gift — the value the donor is anticipated to give — not a raised total.
      1. In Object Manager for Opportunity → **Fields & Relationships**, click the field **Amount**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *The dollar value the donor is expected to give if this Opportunity closes-won. For grants, the request amount; for major gifts, the ask amount.*
      4. In the **Description** field, enter: *On close-won, the FQS Opportunity launcher writes this value into the resulting `GiftCommitment.ExpectedTotalCmtAmount` or `GiftTransaction.OriginalAmount`.*
      5. Click **Save**.

   3. **Add help text and description to `Close Date`.** Required by the platform. On close-won, the FQS launcher writes this into `GiftCommitment.EffectiveStartDate` or `GiftTransaction.TransactionDate` — so it functions as the "when the ask lands" date, not the "when we asked" date.
      1. In Object Manager for Opportunity → **Fields & Relationships**, click the field **Close Date**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *The date this Opportunity is expected to close — award decision date for grants, expected commitment date for major gifts.*
      4. In the **Description** field, enter: *Required by the platform. On close-won, the FQS launcher writes this into `GiftCommitment.EffectiveStartDate` or `GiftTransaction.TransactionDate`.*
      5. Click **Save**.

   4. **Add help text and description to `Probability (%)`.** Probability defaults from the selected Stage — the platform maintains a Stage → Probability mapping in Opportunity Stage setup. Users can override on a per-record basis, but the override is not reflected back in the stage default. FQS forecasting reports weight expected revenue by this field.
      1. In Object Manager for Opportunity → **Fields & Relationships**, click the field **Probability (%)**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *Likelihood this Opportunity closes-won, as a percentage. Defaults from the selected Stage — override only when you have Opportunity-specific intelligence.*
      4. In the **Description** field, enter: *Stage → Probability mapping is managed at the platform level. Manual override is per-record and does not update the stage default.*
      5. Click **Save**.

6. **Configure Gift Designation**

   Complete the following edit in a **Setup → Object Manager → Gift Designation** visit.

   1. **Configure Search Layouts.** Gift Designation is in the FQS Console app; apply the following field selections so admins can spot at a glance which designations are active, which is the org-wide default, and how much has been credited to each.

      Recommended fields on both search layouts (**Default Layout** / Tab, **Search Results**):

      * FQS Restriction Type
      * Active
      * Is Default
      * Total Transaction Amount

      1. In Object Manager for Gift Designation, select **Search Layouts**.
      2. Click **Edit** on **Default Layout**.
      3. Move the four fields above into **Selected Fields** and click **Save**.
      4. Repeat for **Search Results**.

7. **Apply the additional standard-field help text and descriptions**

   Beyond the fields covered in the per-object steps above, FQS recommends Help Text and Description on additional Nonprofit Cloud–owned standard fields across Gift Commitment Schedule, Outreach Source Code, Campaign, Gift Transaction, Gift Tribute, Gift Refund, Campaign Member, Gift Batch, and other objects. Salesforce does not ship help-text or description edits to standard fields in unmanaged packages, so these are applied manually.

   The paste-ready checklist lives at [`docs/manual-help-text-setup.md`](docs/manual-help-text-setup.md). The document is organized in three tiers:

   * **Tier 1 — ✔ already in README:** the 15 automation-critical fields walked through in the per-object steps above (Gift Transaction, Gift Commitment, Opportunity, Gift Designation). Skip this section if you followed the README start-to-finish.
   * **Tier 2 — critical standard fields on non-key objects:** ~12 additional fields where the help text protects FQS or platform automation (Gift Commitment Schedule mechanics, Outreach Source Code UTM mapping). Apply these next. Estimated time: 10–15 minutes.
   * **Tier 3 — additional recommendations:** the remaining fields where help text is nice-to-have (parity, convention, clarity) but not automation-critical. Apply at your leisure. Estimated time: 30–40 minutes.

   Open the doc in your working copy or on the FQS GitHub page, then walk each object → Fields & Relationships → field edit and paste the Help Text and Description into the corresponding fields.

8. **Configure Gift Entry field mappings**

   FQS ships 12 custom fields on the `GiftEntry` staging object that need to carry their values through to the downstream `GiftTransaction` or `GiftCommitment` on commit. Those mappings live in Salesforce's `FieldMappingConfig` metadata, which the unmanaged package cannot ship in source format (see `docs/fqs-fieldmappingconfig-install.md` for the deploy-time bug that forced this carve-out). This step creates the 12 mappings manually via the Setup UI. Estimated time: 10–15 minutes.

   1. From Setup, search for and open **Fundraising Setup**.
   2. Under **Gift Entry**, click **Field Mapping**.
   3. If no Field Mapping Set exists yet, click **New Field Mapping Set**, name it `FieldMappingConfig`, and set:
      * **Source Object:** Gift Entry
      * **Process Type:** Gift Entry
   4. For each row in the table below, click **New Mapping** and enter the source field, destination object, destination field, and sequence exactly as shown. Save each row before moving to the next.

      | Sequence | Source field (on GiftEntry)              | Destination object | Destination field                        |
      | -------- | ---------------------------------------- | ------------------ | ---------------------------------------- |
      | 1        | FQS Gift Transaction Category            | Gift Transaction   | FQS Gift Transaction Category            |
      | 2        | FQS Donor Tax Date                       | Gift Transaction   | FQS Donor Tax Date                       |
      | 3        | FQS Fair Market Value Amount             | Gift Transaction   | FQS Fair Market Value Amount             |
      | 4        | FQS Match Status                         | Gift Transaction   | FQS Match Status                         |
      | 5        | FQS GC Restriction Release Date          | Gift Commitment    | FQS Restriction Release Date             |
      | 6        | FQS GT Restriction Release Date          | Gift Transaction   | FQS Restriction Release Date             |
      | 7        | FQS GC Skip Naming                       | Gift Commitment    | FQS Skip Naming                          |
      | 8        | FQS GT Skip Naming                       | Gift Transaction   | FQS Skip Naming                          |
      | 9        | FQS Stewardship Date                     | Gift Transaction   | FQS Stewardship Date                     |
      | 10       | FQS Stewardship Status                   | Gift Transaction   | FQS Stewardship Status                   |
      | 11       | FQS Tax Receipt Date                     | Gift Transaction   | FQS Tax Receipt Date                     |
      | 12       | FQS GC Match Eligible                    | Gift Commitment    | FQS Match Eligible                       |

   5. When all 12 rows are in place, spot-check by opening a Gift Entry record in the FQS app, populating any one of the source fields (e.g., Stewardship Date), committing the gift, and confirming the value landed on the corresponding downstream Gift Transaction or Gift Commitment record.

   Notes:

   * Rows 5–8 look duplicative but are intentional — a `FieldMappingConfig` enforces "one source → one destination", so a canonical FQS field that lives on both Gift Commitment and Gift Transaction (Restriction Release Date, Skip Naming) needs two paired staging columns (`FQS_GC_*` and `FQS_GT_*`) with two separate mappings.
   * Developers preferring a scripted install can use the Tooling API path documented in `docs/fqs-fieldmappingconfig-install.md`.

**VI. Configure Designation and Tribute Objects**

1. **Establish an org-wide default Gift Designation**

   Nonprofit Cloud Fundraising's platform actions (`processGiftCommitment`, the schedule fanout engines) require exactly one active `GiftDesignation` with `IsDefault = true` before they will accept new gifts. Without this designation in place, the platform aborts with `org wide default designation is not yet configured` and no gift can be saved. The FQS Single Gift Entry launcher enforces the same requirement up front — if it can't resolve a designation through the campaign or commitment defaults and the org has no default designation configured, the launcher stops at a hard-block screen and directs the admin here rather than letting the platform fail the save with a cryptic error later.

   Do this **before** assigning gift-entry permission sets to end users.

   1. **Option A (recommended): run the FQS Suggest Designations flow.**
      1. From the **App Launcher**, search for **Flows** and open the **Flows** setup page.
      2. Locate **FQS Suggest Designations** in the list and click **Run**.
      3. The flow installs a curated 14-designation catalog covering the four `FQS_Restriction_Type__c` values (Without Donor Restriction, Purpose Restriction, Permanent Restriction, Earned Revenue) and flags **FQS General Operating Fund** as the org-wide default. Review the picks before saving; you can safely re-run the flow later to add more designations without disturbing the default.

   2. **Option B: flag an existing Gift Designation as default manually.**
      1. From the **App Launcher**, search for **Gift Designations** and open the tab.
      2. Open the Gift Designation you want as the org-wide default. If none exist yet, create one first (Name, `FQS_Restriction_Type__c = Without Donor Restriction`, `IsActive = true`).
      3. On the record, check **Is Default** and click **Save**.
      4. Only one active Gift Designation can carry `IsDefault = true` at a time. If you change your mind later, uncheck the flag on the previous default before setting it on the new one.

   3. **Verify the default is set.**
      1. From Developer Console (or any tool that runs SOQL), run: `SELECT Id, Name, FQS_Restriction_Type__c FROM GiftDesignation WHERE IsDefault = true AND IsActive = true`.
      2. Confirm exactly one row is returned. Zero rows means the platform will reject new gifts; multiple rows means an earlier configuration is stale and should be cleaned up before proceeding.

   *Notice: If a user launches gift entry before this step is complete, the launcher will present a "Set up designations before continuing" screen and exit. Complete this section, then have the user relaunch from the donor's Account page.*

2. **Configure Gift Designation**

   Complete the following edits in a **Setup → Object Manager → Gift Designation** visit.

   1. **Add help text and description to `Is Default`.** `GiftDesignation.IsDefault` is load-bearing — the managed `processGiftCommitment` action aborts with *"org wide default designation is not yet configured"* if no active designation has `IsDefault = true`. Only one active designation may carry the flag at a time; to retire the current default, promote a successor first. The help text prevents an admin from accidentally clearing the flag during a routine designation cleanup pass.
      1. In Object Manager for Gift Designation, select **Fields & Relationships**.
      2. Click the field **Is Default**.
      3. Click **Edit**.
      4. In the **Help Text** field, enter: *Check exactly ONE active designation as the org-wide default — usually the general operating fund. Gifts that arrive without an explicit designation split fall through to this bucket.*
      5. In the **Description** field, enter: *Load-bearing. The managed `processGiftCommitment` aborts with "org wide default designation is not yet configured" if no active GD has IsDefault=true. FQS seed flags FQS-GD-GENERAL-OPERATING on install. Only one GD may be IsDefault=true at a time; the platform enforces uniqueness across active records. To retire the current default, promote a successor first.*
      6. Click **Save**.

   2. **Add help text and description to `Active`.** Deactivation (`IsActive = false`) is how designations get retired without breaking historical Gift Transaction Designation splits. The platform blocks direct delete of an active designation (*"You can't delete an active designation"*); the correct teardown order is un-default → deactivate → delete.
      1. In Object Manager for Gift Designation → **Fields & Relationships**, click the field **Active**.
      2. Click **Edit**.
      3. In the **Help Text** field, enter: *Uncheck to retire this designation. Retired designations stay on historical gifts but won't appear when adding new gifts.*
      4. In the **Description** field, enter: *Controls availability on new GiftTransactionDesignation splits via the GiftDesignationId lookup filter. An active GD cannot be deleted — the platform raises "You can't delete an active designation." Teardown pattern is un-default (IsDefault=false) → deactivate (IsActive=false) → delete. Deactivation does NOT affect existing historical GTD rows.*
      5. Click **Save**.

3. **Configure Gift Default Designation**

   Complete the following edit in a **Setup → Object Manager → Gift Default Designation** visit.

   1. **Add the Active-Designation lookup filter to `Designation`.** By default, the Designation lookup lets users pick any Gift Designation, including designations that have been retired (`IsActive = false`). Left as-is, this makes it easy for users to attach a payment schedule to a designation the finance team has explicitly closed. Add a lookup filter that restricts the picker to active designations, while still allowing users to override for legitimate exceptions (e.g., a back-dated correction to a retired designation).
      1. In Object Manager for Gift Default Designation, select **Fields & Relationships**.
      2. Click the field **Designation**.
      3. Scroll down to **Lookup Filter** and click **Edit**.
      4. Select **Show only records that match the filter criteria (Optional)**. This activates the filter but leaves an *"Show all results"* toggle in the picker so users can still bypass the filter and select a retired designation when needed.
      5. Add the following filter criterion:
         * **Field:** Gift Designation: Active
         * **Operator:** equals
         * **Value:** True
      6. Under **Filter Type**, confirm the filter is set to **Optional**. FQS ships this filter as Optional so admins can override in edge cases; changing to Required removes the override.
      7. In the **Error Message** field, enter: *This is not an active Gift Designation. Uncheck the "Filter by:" checkbox in the lookup dialog to see all designations, including inactive ones.*
      8. Click **Save**.

   *Notice: This differs from the Stakeholder Management Quick Start convention, which uses a Required filter on similar lookups. FQS deliberately allows the override to accommodate finance corrections against retired designations.*

4. **Configure Gift Transaction Designation**

   Complete the following edit in a **Setup → Object Manager → Gift Transaction Designation** visit.

   1. **Add the Active-Designation lookup filter to `Designation`.** Same rationale and settings as Gift Default Designation step 3.1.
      1. In Object Manager for Gift Transaction Designation, select **Fields & Relationships**.
      2. Click the field **Designation**.
      3. Scroll down to **Lookup Filter** and click **Edit**.
      4. Select **Show only records that match the filter criteria (Optional)**.
      5. Add the following filter criterion:
         * **Field:** Gift Designation: Active
         * **Operator:** equals
         * **Value:** True
      6. Confirm **Filter Type** is **Optional** (matches the FQS convention on Gift Default Designation).
      7. In the **Error Message** field, enter: *This is not an active Gift Designation. Uncheck the "Filter by:" checkbox in the lookup dialog to see all designations, including inactive ones.*
      8. Click **Save**.

5. **Configure Gift Tribute**

   Complete the following edit in a **Setup → Object Manager → Gift Tribute** visit.

   1. **Add the Person-Account lookup filter to `Honoree Contact`.** By default, the Honoree Contact lookup on Gift Tribute lets users pick any Account (including organizations and households). FQS restricts the picker to Person Accounts so tributes are attributed to a specific individual honoree, matching the field's intended semantic. Unlike the designation lookup filters shipped as Optional, this filter ships **Required** — organizational and household tributes are not a supported pattern and would produce ambiguous acknowledgement copy.
      1. In Object Manager for Gift Tribute, select **Fields & Relationships**.
      2. Click the field **Honoree Contact**.
      3. Scroll down to **Lookup Filter** and click **Edit**.
      4. Select **Show only records that match the filter criteria (Required)**.
      5. Add the following filter criterion:
         * **Field:** Account: Is Person Account
         * **Operator:** equals
         * **Value:** True
      6. In the **Error Message** field, enter: *Select an individual (Person Account) for the honoree contact.*
      7. Click **Save**.

   Standard-field help text on `Tribute Type` is covered by the Tier 3 recommendations in [`docs/manual-help-text-setup.md`](docs/manual-help-text-setup.md) (see step V.7).

**VIII. Review and Customize Donor Tiers**

The accelerator ships with a `FQS_Donor_Tier__mdt` custom metadata type that defines three donor tiers — Entry, Mid, and Major. These records serve two purposes: (1) they set the dollar thresholds used by flows and formula fields to classify each gift, and (2) they control how the Gift Acknowledgement flow routes each donor tier between automated emails and personal-touch tasks. **Review and adjust these before activating the Gift Acknowledgement flow.**

**Understanding the fields**

Each `FQS_Donor_Tier__mdt` record has the following fields:

| Field | What it does |
|---|---|
| **Branded Name** (`Branded_Name__c`) | The organization's specific naming structure for public donor recognition, shown in reports, dashboards, and the Donor Gift Summary record page. Example values: Friend, Partner, Champion or Entry, Rising, Summit. Change this freely. |
| **Tier Key** (`Tier_Key__c`) | The generic donor tiers (`Entry`, `Mid`, `Major`) used by formula fields and the acknowledgement flow to classify donors. **Do not change.** |
| **One-Time Min Amount** (`One_Time_Min_Amount__c`) | Minimum single-transaction gift amount to qualify for this donor tier. Updating this recalculates the giving level across all Gift Transactions. |
| **Annual Min Amount** (`Annual_Min_Amount__c`) | Minimum fiscal-year giving total to qualify. Updating this recalculates the annual giving level across all Donor Gift Summary records. |
| **Lifetime Min Amount** (`Lifetime_Min_Amount__c`) | Minimum cumulative lifetime giving to qualify. Used as an escalation threshold by the `Exclude Lifetime` acknowledgement setting. Updating this recalculates lifetime giving level across all Donor Gift Summary, Gift Commitment, and related records. |
| **Auto Stewardship** (`FQS_Auto_Stewardship__c`) | Controls how the Stewardship Response flow handles gifts at this donor tier (Include All / Exclude Lifetime / Exclude All). See picklist logic below. Governs the ~14-day stewardship touch — acknowledgement itself is a universal rule and does not consult this field. |
| **Credit Type** (`Credit_Type__c`) | Determines which giving totals count toward this tier. `Hard Credits Only` (default) counts the donor's own gifts (`TotalGiftsAmount` / `GiftsThisYearAmount` + FQS legacy hard credits). `Hard + Soft Credits` also counts soft-credit totals (`TotalSoftCreditsAmount` / `CurrentYearSoftCreditsAmount` + FQS legacy soft credits) — spouse-attributed gifts, foundation-driven gifts recognized to the donor. Set independently per tier: a Major tier can count soft credits while an Entry tier stays hard-only. |
| **Sort Order** (`Sort_Order__c`) | Controls display order in Setup and reports. Lower numbers appear first. This field is presentation-only and is edited from Setup → Custom Metadata Types (the FQS Setup flow does not surface it). |

**Packaged default values**

| Tier | Tier Key | Branded Name | One-Time Min | Annual Min | Lifetime Min | Auto Stewardship |
|---|---|---|---|---|---|---|
| Entry | `Entry` | Friend | $1 | $100 | $500 | Include All |
| Mid | `Mid` | Partner | $250 | $3,000 | $15,000 | Exclude Lifetime |
| Major | `Major` | Champion | $500 | $5,000 | $25,000 | Exclude All |

*These defaults are illustrative starting points. Most organizations have different thresholds. Adjust them to match your development team's definitions before going live.*

**Understanding the Auto Stewardship picklist**

The `FQS_Auto_Stewardship__c` picklist on each donor tier directly controls how the Gift Acknowledgement flow routes a gift at that donor tier. There are three values:

* **Include All** — The flow sends an automated acknowledgement email for every gift in this donor tier (unless the donor has opted out of email). Typical use: entry-level gifts where personal outreach is not warranted.
* **Exclude Lifetime** — The flow sends an automated email, *except* when the donor has already reached or exceeded the donor tier's **Lifetime Min Amount** threshold. In that case, the flow creates a Task instead, prompting a staff member to reach out personally. Typical use: mid-level donors where loyal long-term givers deserve a human touch.
* **Exclude All** — The flow always creates a Task assigned to the FQS Gift Acknowledgements queue rather than sending an automated email. Typical use: major gifts where every acknowledgement should be personal, regardless of lifetime giving.

**How to edit donor tiers**

You have two ways to edit donor tiers:

**Option A (recommended): Use the FQS Setup screen flow**

The **FQS Setup** flow ships with the accelerator and provides a guided UI for editing thresholds and acknowledgement routing on all three donor tiers in one pass. It is available from:

* The **Setup** tab inside the **Fundraising Quick Start** Lightning app, or
* The **Setup** utility-bar item at the bottom of the app.

Steps:

1. Open the **Fundraising Quick Start** app.
2. Click the **Setup** tab (or the Setup utility-bar item).
3. Pick one of two setup subflows:
   * **Donor Tier Thresholds** — edits the Branded Name, One-Time Min, Annual Min, Lifetime Min, and **Credit Type** (Hard Credits Only vs Hard + Soft Credits) for each of the three donor tiers in one screen.
   * **Stewardship Response Settings** — edits the per-tier Auto Stewardship setting (Include All / Exclude Lifetime / Exclude All) with a "set all three to the same value" shortcut.
4. Complete the screens, click **Next**, then **Finish**.
5. Changes are queued as an asynchronous metadata deployment. New values typically take up to a minute to appear on records. You can watch progress in **Setup → Deployment Status** if needed.

The FQS Setup flow only edits the three seeded donor tiers — it does not create new ones. Use Option B below to add donor tiers beyond Entry/Mid/Major.

**Option B: Use Setup → Custom Metadata Types**

Donor Tier records are custom metadata — they can also be edited (and added) directly through Setup.

1. From **Setup**, in the **Quick Find** box, enter **Custom Metadata Types**, and then select **Custom Metadata Types**.
2. Click **Manage Records** next to **FQS Donor Tier** in the list.
3. Click **Edit** next to the donor tier you want to modify (Entry, Mid, or Major), or **New** to add a new one.
4. Update the fields as needed:
   1. Change **Branded Name** to your organization's terminology (e.g., "Supporter", "Sustainer", "Leadership Circle").
   2. Adjust **One-Time Min Amount**, **Annual Min Amount**, and **Lifetime Min Amount** to match your development team's definitions.
   3. Set **Auto Stewardship** to the routing behavior appropriate for this donor tier (see picklist logic above).
   4. Adjust **Sort Order** if needed (lower numbers appear first).
   5. Leave **Tier Key** unchanged on the three seeded records.
5. Click **Save**.
6. Repeat for each donor tier.

*Notice: Tier Key values (`Entry`, `Mid`, `Major`) are hard-coded in the Gift Acknowledgement flow and in formula fields on Donor Gift Summary, Gift Commitment, and Gift Transaction as lookup keys. Changing them on the three seeded records will break formula evaluation. If you add donor tiers beyond Entry/Mid/Major, you will also need to review and update the formula fields and flow logic that reference them.*

Supporting documentation:

* [Custom Metadata Types](https://help.salesforce.com/s/articleView?id=platform.custommetadatatypes_overview.htm&type=5)
* [Add and Edit Custom Metadata Records](https://help.salesforce.com/s/articleView?id=platform.custommetadatatypes_populating.htm&type=5)

---

**IX. Review and Activate the Gift Acknowledgement Flow**

The **FQS Gift Acknowledgement** flow is a daily-scheduled AutoLaunched flow on the Gift Transaction object. It picks up gifts with `Status='Paid'` and no acknowledgement stamp yet, then routes each to either an automated email or a personal-touch Task based on a universal rule — every donor with a valid email address receives the acknowledgement email; opt-outs and blank emails route to a Task in the acknowledgement queue. The follow-on **FQS Stewardship Response** flow (scheduled daily, fires ~14 days after acknowledgement) is what consults the `FQS_Auto_Stewardship__c` per-tier setting configured in the previous section.

**The flow is deployed in an inactive state.** Because it sends outbound emails to donors, it must be reviewed and intentionally activated by an admin rather than going live automatically on install.

**What the flow does**

1. **Entry check** — If the Gift Transaction is no longer `Paid` or has already been acknowledged (AcknowledgementStatus = `Acknowledged`) when the scheduled path fires, the flow exits without action.
2. **Resolve donor tier** — The flow reads `FQS_Is_Major_Gift__c` and `FQS_Is_Mid_Gift__c` on the Gift Transaction to determine the resolved donor tier (`Major`, `Mid`, or `Entry`). These checkboxes are set by your gift entry process or a separate classification automation.
3. **Look up CMDT record** — The flow queries `FQS_Donor_Tier__mdt` for the matching `Tier_Key__c` (`Major`, `Mid`, or `Entry`) and reads the donor tier's `FQS_Auto_Stewardship__c` value.
4. **Route: Email or Task**
   * **Include All** → Sends an automated acknowledgement email to the donor's email address (skipped if the donor has opted out of email).
   * **Exclude Lifetime** → Sends the automated email, unless the donor's lifetime giving has reached or exceeded the donor tier's `Lifetime_Min_Amount__c` — in that case, creates a Task instead.
   * **Exclude All** → Creates a Task assigned to the **FQS Gift Acknowledgements** queue for staff follow-up.
5. **Update status** — After a successful email send, the flow updates `AcknowledgementStatus` to `Acknowledged` on the Gift Transaction.
6. **Fault handling** — If the email action fails, the flow sends a fault notification to the running user rather than failing silently.

**Before you activate**

1. **Complete section VIII** — Confirm that your Donor Tier thresholds and Auto Stewardship settings reflect your organization's donor tiers and outreach philosophy.

2. **Review and customize the email content** — The flow uses the platform's `emailSimple` action with the shipped Classic email templates in the **FQS Templates** folder. Two templates carry the acknowledgement body:
   * `FQS_Gift_Acknowledgement` — universal thank-you.
   * `FQS_Gift_Acknowledgement_Partial` — used automatically when `TaxDeductionAmount < CurrentAmount`.

   Edit both from **Setup → Email → Classic Email Templates → FQS Templates**. Each contains a `[PROVIDE SOME INFO ABOUT YOUR HISTORY, A SPECIFIC PROGRAM, PERSON, OR YOUR TOTAL IMPACT]` placeholder that must be replaced with your organization's copy before activating the flow. See §10 (Email Templates for Acknowledgement and Stewardship) for the full editing walkthrough, including the optional rebuild-in-Lightning-Email-Builder path.

   The email subject is set on the **Send Acknowledgement Email** action element inside the flow, not on the template. Edit it in Flow Builder (Setup → Flows → FQS Gift Acknowledgement) if you want a subject line other than the default `"Thank you for your gift!"`.

3. **Verify the FQS Gift Acknowledgements queue exists** — Gifts routed to **Exclude All** or **Exclude Lifetime** (lifetime escalation) create Tasks owned by this queue. Confirm the queue exists and has the right members before activating.
   1. From **Setup**, in the **Quick Find** box, enter **Queues**, and then select **Queues**.
   2. Confirm **FQS Gift Acknowledgements** is listed.
   3. Click the queue name and verify the **Queue Members** list includes the appropriate gift officers or development staff.

4. **Verify `FQS_Is_Major_Gift__c` and `FQS_Is_Mid_Gift__c` are being populated** — The flow's tier-resolution logic reads these checkbox fields on the Gift Transaction. If they are not being set by your gift entry process or a classification flow, the flow will default every gift to the `Entry` donor tier. Confirm how these fields are populated in your org before activating.

5. **Test in a sandbox** — Create a test Gift Transaction, set its status to `Paid`, wait for the next daily run of the flow (or trigger it manually from Setup → Flows), and verify it routes to the expected email or Task.

**Activate the flow**

1. From **Setup**, in the **Quick Find** box, enter **Flows**, and then select **Flows**.
2. Locate **FQS Gift Acknowledgement** in the list.
3. Click the flow name to open it in Flow Builder.
4. Click **Activate** in the upper right.
5. Confirm the status changes to **Active**.

*Notice: Activating this flow will cause it to send automated emails to donors whose Gift Transactions are set to Paid after activation. Do not activate until you have reviewed the email content and confirmed your Donor Tier settings are correct. Test in a sandbox first.*

Supporting documentation:

* [Activate or Deactivate a Flow](https://help.salesforce.com/s/articleView?id=platform.flow_distribute_activate.htm&type=5)
* [Scheduled Paths in Record-Triggered Flows](https://help.salesforce.com/s/articleView?id=platform.flow_ref_elements_scheduledpaths.htm&type=5)
* [Create and Manage Queues](https://help.salesforce.com/s/articleView?id=platform.setting_up_queues.htm&type=5)

---

**XII. Home Page Review and Walkthrough**

With Post-Install steps I through XI complete, the FQS home page inside the Fundraising Quick Start Lightning app becomes your review checkpoint and end-user walkthrough surface. The main accordion mirrors the nine day-to-day fundraising milestones FQS expects an org to master — Gift Designations, Campaign Hierarchy / Outreach Source Codes, Donor Tiers, Gift Entry Grid, Guided Gift Entry, Acknowledgement and Stewardship, Stewardship Response Settings, Automation and Queue Membership, and finally Home Page replacement. Walk each accordion section top-to-bottom to confirm the corresponding setup work is in place and to introduce new admins to the accelerator's shape.

* **1. Set Up Gift Designations** — establish your active designation catalog, flag the org-wide default, and align `FQS_Restriction_Type__c` values with your finance team's chart of accounts. Ties back to Post-Install step VI.1.
* **2. Establish Solicitation and Outreach Tracking (Campaign Hierarchy)** — build your first Campaign Hierarchy with the FQS Campaign Hierarchy Setup flow, then let the platform auto-create placeholder Outreach Source Codes on each Tactical campaign. Ties back to Post-Install step VII.3.
* **3. Define Donor Tiers and Thresholds** — review the packaged Entry / Mid / Major tier defaults and adjust the dollar thresholds and credit-type settings to match your development team's definitions. Ties back to Post-Install step VIII.
* **4. Enter Gift Batches with Gift Entry Grid** — the batch-oriented gift-entry surface for development staff. Walks the reader through creating a Gift Batch and posting gifts through the grid.
* **5. Review Guided Gift Entry** — the FQS guided single-gift-entry flow. Walks the reader through launching from a donor's Account or the FQS launcher tile on the home page.
* **6. Guidance on Acknowledgement, Stewardship, and Tax Receipting** — the FQS date model (Transaction Date vs. Donor Tax Date vs. Acknowledgement Date vs. Tax Receipt Date) and the two-flow acknowledgement + stewardship pattern. Cross-references Post-Install Considerations §9 (How FQS Thinks About Gift Dates) and §10 (Email Templates).
* **7. Configure Stewardship Response Settings** — the per-tier Auto Stewardship setting (Include All / Exclude Lifetime / Exclude All) that controls how the Gift Stewardship flow routes each donor. Ties back to Post-Install step VIII.
* **8. Review Automation and Queue Membership** — audit the FQS record-triggered and scheduled flows, verify the four FQS queues (`FQS_Gift_Acknowledgements`, `FQS_Stewardship_Tasks`, `FQS_Gift_Processing_Tasks`, `FQS_Executive_Fundraising_Tasks`, `FQS_Major_Donor_Tasks`) have the right members, and confirm the Gift Acknowledgement flow is only activated after §IX is complete.
* **9. Update Home Page** — replace the FQS-shipped home page with your organization's operational home page once setup is complete. The FQS home page is a walkthrough surface, not a day-to-day dashboard; day-to-day users should land on a page tuned to your team's workflows.

**Flow Resources:**

* **Introductory Guide:** [What Is a Screen Flow?](https://admin.salesforce.com/blog/2023/what-is-a-screen-flow)
* **Process Automation:** [Extend Salesforce with Click-Not-Code Processes](https://help.salesforce.com/s/articleView?id=sf.extend_click_process.htm&type=5)
* **Core Documentation:** [Platform Automation Overview](https://help.salesforce.com/s/articleView?id=platform.platform_automation.htm&type=5)
* **Trailhead Trail:** [Build Flows with Flow Builder](https://trailhead.salesforce.com/content/learn/trails/build-flows-with-flow-builder)

## Post-Install Considerations: Making This Work For You In Your Existing Setup

While this package installs a standalone custom app, it is highly likely that your fundraising operation is already entangled with other processes across your organization (stakeholder management, programs, grants, case management, marketing). Rather than forcing users to switch between disconnected apps, **the goal of this post-install process is to adopt and integrate these new components—the modular flows, custom fields, dynamic pages, and record types—into your primary, existing business apps.** Use the following steps to review, adjust, and embed the accelerator into your live environment.

### 1. Review Agentforce Nonprofit / Nonprofit Cloud Fundraising Setup Steps

Fundraising is a component of Agentforce Nonprofit / Nonprofit Cloud and has substantial additional functionality beyond what this accelerator configures. Beyond the settings enabled in "Before You Install," looking at the applicability of Gift Entry Batches, Gift Matching, Recurring Donations, Interaction Summaries, and Timeline features may be relevant to your use of Fundraising.

**Salesforce Documentation**

<!-- TODO: curate the exact Help/Trailhead links that best match this accelerator's scope. Candidates:
* Nonprofit Cloud Fundraising Prerequisites
* Set Up Gift Entry
* Manage Recurring Gifts
* Track Gifts with Designations
* Fundraising Reporting
-->

* **Setup Guide:** [Complete Nonprofit Cloud Prerequisites](https://help.salesforce.com/s/articleView?id=sfdo.npc_prerequisites.htm&type=5)
* **Trailhead Module:** <!-- TODO: link to a Fundraising-in-Nonprofit-Cloud Trailhead module -->

### 2. Review Profiles and Permission Sets

The package does not include rigid, pre-packaged permission sets for field, object, and flow access. You will need to design your own access strategy based on your data governance model:

* **Determine Data Entry Paths:** Decide how and where your users will enter gifts (Gift Entry, Gift Batch, direct object creation, integrated payment processors) and design permission sets to remove options that will not be supported.
* **Segregate Duties:** Gift entry, gift adjustment/refund, and gift acknowledgement are commonly done by different people. Consider building permission sets that map cleanly to those duties rather than granting blanket access to the Fundraising object family.
* **Build Custom Permission Sets and Groups:** The accelerator includes a basic **FQS Custom Fields** permission set for you to adopt and merge with your own custom permission sets and groups.

**Salesforce Documentation:**

* **Core Guide:** [Permission Sets Overview](https://help.salesforce.com/s/articleView?id=platform.perm_sets_overview.htm&language=en_US&type=5)
* **Assignment Guide:** [Manage Permission Set Assignments](https://help.salesforce.com/s/articleView?id=platform.perm_sets_manage_assignments.htm&language=en_US&type=5)
* **Best Practices:** [Guidelines for Creating Permission Sets and Permission Set Groups](https://help.salesforce.com/s/articleView?id=platform.perm_sets_best_practices.htm&language=en_US&type=5)

### 3. Review Lightning Apps, Pages, and Page Layouts

To deliver a seamless user experience, transition the components from the standalone package app into your primary operational apps:

**Migrate Dynamic Pages:** Review the dynamic Lightning record pages provided by the package for Gift Transaction, Gift Commitment, Gift Designation, Gift Refund, Gift Tribute, Donor Gift Summary, Outreach Source Code, Outreach Summary, Payment Instrument, Campaign, and Opportunity. Instead of using the default standalone app layout, use the Lightning App Builder to assign these dynamic pages (or migrate their conditional visibility components) to your organization's primary working apps.

**Consolidate Page Layouts:** Audit your existing Gift Transaction and Gift Commitment page layouts to embed the custom fields (like `FQS_Gift_Transaction_Category__c`, `FQS_In_Kind__c`, `FQS_Match_Status__c`, `FQS_Restriction_Type__c`) and replace standard related lists with the package's modular components where appropriate.

**Salesforce Documentation:**

* **Guide:** [Break Up Your Record Details with Dynamic Forms](https://help.salesforce.com/s/articleView?id=platform.dynamic_forms_overview.htm&language=en_US&type=5)
* **Access Control:** [Assign Record Types and Page Layouts in Profiles](https://help.salesforce.com/s/articleView?id=platform.users_profiles_record_types.htm&type=5)
* **Trailhead Module:** [Lightning App Builder](https://trailhead.salesforce.com/content/learn/modules/lightning_app_builder)

### 4. Establish Data Integrity Guardrails

Because the accelerator relies on background automation and admin-configured picklists without hardcoded restrictions, you should establish your own guardrails before roll-out:

**Provide Guardrails for Financial Fields:** Create custom Validation Rules to lock critical financial data points (Original Amount, Current Amount, Designation splits, Refund Amount) after a gift is posted. This prevents users from accidentally re-opening closed accounting periods or corrupting historical totals.

**Enforce Mutual Exclusion on Corporate Match Flags:** The Account fields `FQS_Matching_Gift_Program__c` and `FQS_Is_Match_Intermediary__c` are intended to be mutually exclusive — an Account is either a true corporate running a match program, or an intermediary (Benevity, YourCause, Bright Funds, CyberGrants) that facilitates matches on behalf of other corporates. If both are checked on the same Account, the Find Match screen flow will fork ambiguously. Consider adding a custom Validation Rule such as `NOT(AND(FQS_Matching_Gift_Program__c, FQS_Is_Match_Intermediary__c))` on Account to prevent this. The accelerator does not ship this rule so that admins can decide whether to enforce it, warn only, or handle it in their own data-quality process.

**Evaluate a Lookup Filter on `Account.ParentId` to Scope the Employer Match Picker Fallback:** The FQS Single Gift Entry launcher's employer-match branch shows a two-stage employer picker: a datatable of employers already related to the donor through Account-Contact Relationships whose linked group is a `PartyRelationshipGroup` of `Type = 'Group'` (Household PRGs are excluded automatically), plus a fallback Account search bound to `Account.ParentId` for cases where the desired organization isn't on the donor's ACR list. The datatable path is pre-filtered by design and needs no admin configuration. The fallback lookup, however, inherits any platform-configured field-level lookup filter on `Account.ParentId`. Person Accounts are automatically excluded by Salesforce, but *Household* Accounts (Business Account record type in Nonprofit Cloud) are not — without a filter, users can search up any Account including households. Evaluate adding a lookup filter on `Account.ParentId` such as `Account.RecordType.DeveloperName NOT IN ('HH_Account', 'Household')` (adjust for your org's household record-type API name) — or, more restrictively, `Account.FQS_Matching_Gift_Program__c = true` if you only want previously-validated matching corporates to appear in the fallback search. The launcher's employer-picker screen surfaces a help bubble telling users that any admin-configured filter applies, so this configuration is transparent to end users. The accelerator does not ship a lookup filter because household record-type API names and match-program data hygiene vary across orgs.

**Reconcile with Your Chart of Accounts:** The `FQS_Restriction_Type__c` field on Gift Designation and the `FQS_Donor_Tier__mdt` custom metadata type are intentionally admin-editable. Confirm their values match the categories your finance team already uses for external reporting (990, audited financials, board dashboards) rather than inventing new ones.

**Review the Duplicate and Matching Rules that Ship with This Accelerator:** The package deploys three Duplicate Rules and three Matching Rules on Account and Contact, all active and set to **warn (not block)** on Alert + Report actions for insert and update. They coexist with the standard Salesforce rules (which remain at sort order 1); the FQS rules run after and add friendlier alert text with a direct link to the existing record.

* **`FQS_Account_Organization_Dupe`** (sort 2) → **`FQS_Account_Organization_Match`** — matches on `Name` + `BillingCity` (both exact, both required). Intended for Organization-record-type donor Accounts. Household and Person Accounts typically won't hit this rule because they lack a billing city; if your org populates BillingCity on Households, consider adding a duplicate rule condition to scope this rule to the Organization record type.
* **`FQS_Account_Person_Dupe`** (sort 3) → **`FQS_Account_External_Id_Match`** — matches on `External_Id__c`. Fires **before** the platform-level `unique=true` `DUPLICATE_VALUE` exception on that field, giving staff a clearer message and a link to the existing record instead of a raw platform error. Because Account can reference each Matching Rule only once, External Id dedup lives on a separate paired Duplicate Rule from the Name+City dedup above; if you add more Account matching signals, use additional paired rules.
* **`FQS_Contact_Dupe`** (sort 2) → **`FQS_Contact_Individual_Match`** — matches on `FirstName` + `LastName` + `Email` (all three exact, all three required). Blank values are treated as non-matches, so Contacts missing any of the three won't produce false positives.

Standard `Standard_Account_Duplicate_Rule` and `Standard_Contact_Duplicate_Rule` remain active at sort order 1. The standard `Standard_Person_Account_Duplicate_Rule` remains inactive as shipped (FundFirst / Nonprofit Cloud uses the Organization + Person record types on Account, not the classic Person Account object). Standard `Standard_Lead_Duplicate_Rule` is unrelated to the accelerator and left untouched — no FQS component uses Leads.

**When to tune these rules for your org:**

* **Switch from warn to block.** All FQS rules ship with `<operationsOnInsert>Alert</operationsOnInsert>` + `<operationsOnUpdate>Alert</operationsOnUpdate>` (warn-not-block, plus `Report` for reporting). To hard-block saves that hit a match, change the relevant `<operationsOn*>` from `Alert` to `Block` in the rule metadata (or set it via **Setup → Duplicate Rules → the rule → Actions**). Only do this after your team is confident that legitimate near-duplicates (spouses at the same address, family members sharing an email) are rare in your donor data — a Block rule that misfires stops data entry cold.
* **Widen or narrow the Contact match signals.** FirstName + LastName + Email is deliberately conservative to reduce false positives on households. If your data has strong Phone or Mailing Address hygiene, consider a paired Matching Rule using those signals with `Fuzzy: First Name` / `Fuzzy: Last Name` for nickname handling.
* **Scope Account rules by record type.** If Household Accounts share BillingCity with Organization Accounts frequently, add a `<duplicateRuleFilter>` on `FQS_Account_Organization_Dupe` such as `Account.RecordType.DeveloperName = 'Organization'` to prevent household false positives.
* **Deploy order.** If you customize these rules, remember two constraints: (1) a Matching Rule must be deployed and active **before** any Duplicate Rule that references it — this is a two-deploy pattern for greenfield builds; (2) each Duplicate Rule on Account can reference only **one** Matching Rule, so multi-signal dedup (e.g., Name+City OR External Id) requires paired Duplicate Rules like the ones shipped here.

**Review your own additional Duplicate Rules:** If your org already has custom Duplicate Rules on Account, Contact, or Lead, review them alongside these to make sure sort orders, blank-value behavior, and alert text don't conflict. Consider whether you also want dedicated rules for Campaigns of type `FQS_Fundraising` or for the Fundraising objects (Gift Commitment, Gift Transaction, Gift Designation) — the accelerator does not ship dupe rules for those because their duplicate-detection semantics are org-specific.

**Automation Bypass During Bulk Loads:** The accelerator ships an **FQS Bypass Automation** custom permission and matching permission set (`FQS_Bypass_Automation`). Every FQS record-triggered flow that maintains derived state — currently the three flows that recalculate `GiftCommitment.FulfillmentType` (`FQS_GC_Fulfillment_On_Change`, `FQS_GC_Fulfillment_From_GDD`, `FQS_GC_Fulfillment_From_GDD_Delete`) — checks `$Permission.FQS_Bypass_Automation` in its entry criteria and short-circuits when it is TRUE. Assign this permission set to any user or integration whose transactions should skip the per-record recalc (migration runners, Data Loader operators, mass-update jobs). After the bulk load completes, run `scripts/apex/fqs-recalc-gc-fulfillmenttype.apex` (via `sf apex run -f scripts/apex/fqs-recalc-gc-fulfillmenttype.apex`) to reconcile `FulfillmentType` on every Gift Commitment; the script is idempotent (writes only when the target value differs) and safe to re-run. As additional derived-state flows are added to FQS, they should gate on the same permission so operators have one bypass switch rather than a per-flow toggle.

**Salesforce Documentation:**

* **Validation Rules Guide:** [Validation Rules Documentation](https://help.salesforce.com/s/articleView?id=platform.fields_about_field_validation.htm&language=en_US&type=5)
* **Duplicate Rules Guide:** [Duplicate Rules Map of Reference](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_map_of_reference.htm&type=5)
* **Duplicate Rules Framework:** [Things to Know About Duplicate Rules](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_overview.htm&type=5)
* **Standard OOTB Rules:** [Standard Duplicate Rules Reference](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_standard_rules.htm&type=5)

### 5. Reporting and Dashboards

The accelerator ships three Custom Report Types, seven reports, and one dashboard as a starting analytics library. All three CRTs use a "kitchen-sink" pattern (broad column availability on the base object plus common parent lookups) — extend them or clone into narrower CRTs as your reporting practice matures.

**Custom Report Types (`force-app/main/default/reportTypes/`):**

* **Gift Commitments Deluxe** (`fqs_Gift_Commitments_Deluxe`) — base object `GiftCommitment` with lookups to Donor Account, Campaign, and current schedule.
* **Gift Transactions Deluxe** (`fqs_Gift_Transactions_Deluxe`) — base object `GiftTransaction` with lookups to Donor Account, Campaign, Gift Commitment, and current schedule.
* **Donor Gift Summary Deluxe** (`fqs_Donor_Gift_Summary_Deluxe`) — base object `DonorGiftSummary` (a rollup object populated by the Nonprofit Cloud Fundraising engine) with lookup to Donor Account and the `FQS_Annual_Donor_Level_Name__c` / `FQS_Lifetime_Donor_Level_Name__c` classification fields driven by `FQS_Donor_Tier__mdt`.

**Reports (`force-app/main/default/reports/FQSDonorTierReports/`):**

* **FQS Major Lifetime Donors** — donors whose cumulative giving qualifies for the Major tier as defined by the Major record in `FQS_Donor_Tier__mdt`. All-time scope (no time filter).
* **FQS Major Annual Donors This FY** — donors whose current-fiscal-year giving qualifies for the Major tier. Fiscal-year scope is inherited from the `DonorGiftSummary.GiftsThisYearAmount` rollup, which is fiscal-calendar aware — do not add a report-level `TransactionDate` filter or you will double-count.
* **FQS Major Gifts This Year** — individual gift transactions above the Major single-gift threshold, filtered to `THIS_FISCAL_YEAR`. Answers the "which specific gifts drove our fiscal-year major-donor performance" question rather than aggregating at the donor level.
* **FQS Major Commitments Active** — outstanding major-donor pledges grouped by `Status`, filtered to `Status IN ('Active', 'Failing', 'Paused')` — excludes Completed and Lapsed. Chart shows both record count and `SUM(ExpectedTotalCmtAmount)` for at-a-glance pipeline visibility.
* **FQS Mid to Major Upgrade Pipeline** — mid-tier annual donors (`FQS_Is_Mid_Annual_Donor__c = TRUE AND FQS_Is_Major_Annual_Donor__c = FALSE`) ranked by current fiscal-year giving. Use to prioritize cultivation conversations.
* **FQS Stewardship Pipeline** — Matrix report of Paid contribution transactions over the last six months grouped by `FQS_Stewardship_Status__c` × `FQS_Gift_Transaction_Category__c`. Surfaces gifts stuck in "To Be Sent" past SLA — the operational surface for the daily 07:00 UTC stewardship batch. Excludes fee-for-service and payment transactions by design (those don't warrant stewardship touches).
* **FQS Campaign Performance By Depth** — Summary report of paid-gift totals grouped by `Campaign.FQS_Hierarchy_Depth__c` (1 = rollup, 5 = leaf). Validates that the optional lookup filter shipped on `GiftTransaction.CampaignId` and `GiftCommitment.CampaignId` (see Post-Install step V) is being honored — depth-3 (ask-level) attribution should dominate healthy data. If most gifts land on depth 1 or 2, users are attributing to rollups and reporting is being skewed.

**Dashboard (`force-app/main/default/dashboards/FQSDashboards/`):**

* **FQS Donor Tiers** — eight-component dashboard pairing the reports above. Runs as **Dynamic Dashboard** (`dashboardType = LoggedInUser`), so each viewer sees data scoped to their own record access rather than a fixed running user. This costs one Dynamic Dashboard license slot per subscriber org (Enterprise Edition includes five; Unlimited includes ten) but avoids the tenant-specific `runningUser` problem that would otherwise force each installing admin to re-point the dashboard at their own user. If your org has already exhausted its Dynamic Dashboard allocation, edit the dashboard to `SpecifiedUser` and point `runningUser` at a service-style admin user with read access to the full donor set.

**Adopt or extend:**

* All seven reports live in the shared **FQS Donor Tier Reports** folder with `Shared` access and `ReadWrite` public-folder access — change this to match your access model.
* The lookup filters on `GiftTransaction.CampaignId` and `GiftCommitment.CampaignId` are shipped as `isOptional = true` (warn only, users can bypass). Consider tightening to `isOptional = false` if you want to hard-enforce ask-level attribution — see Post-Install steps V.2 and V.3 for the click-path.
* Deferred future additions the seed already supports but which need policy decisions from your org first: **recurring giving retention** (needs a rolling snapshot policy), **refund and adjustment audit** (needs your refund-reason taxonomy), **outreach source-code attribution** (needs your UTM / channel definitions locked in), and **restriction-type breakdown of committed revenue** (needs your finance team's chart-of-accounts mapping to `FQS_Restriction_Type__c` locked in — see Section 5 above).

**Salesforce Documentation:**

* **Guide:** [Reports and Dashboards Overview](https://help.salesforce.com/s/articleView?id=platform.reports_dashboards.htm&type=5)
* **Custom Report Types:** [Set Up a Custom Report Type](https://help.salesforce.com/s/articleView?id=platform.reports_report_types.htm&type=5)
* **Dynamic Dashboards:** [Set Up Dynamic Dashboards](https://help.salesforce.com/s/articleView?id=platform.dashboards_dynamic_setup.htm&type=5)

### 6. Turn On RFM Scoring

Nonprofit Cloud Fundraising ships a **Recency / Frequency / Monetary (RFM) Score** engine backed by the platform's Data Processing Engine (DPE). When configured, the RFM Score Calculation DPE writes recency, frequency, monetary, and composite RFM scores to the Donor Gift Summary object on a schedule you control via a scheduled Flow. FQS depends on Donor Gift Summary values for the Donor Tier resolution formula fields (`FQS_Is_Entry_Annual_Donor__c`, `FQS_Is_Mid_Annual_Donor__c`, `FQS_Is_Major_Annual_Donor__c` and their Lifetime counterparts), the Donor Gift Summary record page, and the Major Gifts Stale list view on the FQS home page. Without RFM scoring configured and scheduled, those fields remain null and the tier-based automation defaults every donor to Entry.

RFM scoring is authored by each organization because the source fields, weight percentages, range banding, and cadence are org-specific judgment calls that FQS cannot ship as one-size-fits-all defaults. FQS ships an **FQS Rollup DPE Read** permission set to give the Analytics Integration User read access to the standard fields the DPE needs — assign this before you configure RFM so the DPE doesn't fail on FLS during execution.

**Step 1 — Assign the FQS Rollup DPE Read permission set to the Analytics Integration User**

1. From Setup, in the Quick Find box, enter **Users**, and then select **Users**.
2. Filter the list to **All Users** and locate the **Analytics Integration User** (also labeled Analytics Cloud Integration User).
3. Open the user record and click **Permission Set Assignments** → **Edit Assignments**.
4. Add **FQS Rollup DPE Read** to the Enabled Permission Sets column and click **Save**.

**Step 2 — Configure the RFM Score Calculation DPE**

Follow the Salesforce Help article [Set Up RFM Scoring in Nonprofit](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_set_up_rfm_scoring.htm&type=5). The workflow, summarized:

1. From Setup, in the Quick Find box, enter **RFM**, and then select **Recency, Frequency, Monetary Value (RFM) Score**.
2. Click **Configure Scoring**.
3. Set the number of source fields to use for each of the three scoring methods, and click **Next**.
4. **Configure the recency score.** Pick a destination object and field (typically **Donor Gift Summary** → **Recency Score**), pick the source object and field(s) — note that Salesforce uses the same source object for all three scores — set the weight per source (whole-number percentages that sum to 100), and pick the related lookup field that ties the source records to the destination. Click **Next**.
5. **Configure the frequency score.** Same shape as recency; typical destination is Donor Gift Summary → **Frequency Score**. Click **Next**.
6. **Configure the monetary value score.** Same shape as recency; typical destination is Donor Gift Summary → **Monetary Score**. The monetary score can be in any currency as long as the source data is consistent (the DPE does not perform currency conversion).
7. Set the destination for the **composite RFM score** — typically Donor Gift Summary → **Composite RFM Score**. Click **Next**.
8. Select the number of ranges for each score component (e.g., 3 produces low / middle / high bands) and click **Next**.
9. Set the ranges:
   * **Recency** — ascending order, best-scoring band first. Ranges cannot overlap or duplicate.
   * **Frequency** — descending order, most donations first.
   * **Monetary** — descending order, largest gift totals first.
10. Review your settings and **Save**.

**Step 3 — Schedule the RFM Score Calculation DPE via a Schedule-Triggered Flow**

The DPE runs only when invoked. Salesforce Fundraising exposes the DPE as an action inside a Schedule-Triggered Flow, giving you full control of frequency and start time. Follow the Salesforce Help article [Schedule RFM Score Calculation in Nonprofit](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_create_schedule_triggered_flow_to_run_dpe_jobs.htm&type=5). The workflow, summarized:

1. From Setup, in the Quick Find box, enter **Flows**, and then select **Flows**.
2. Click **New Flow** → **Start From Scratch** → **Next**.
3. Select the **Schedule-Triggered Flow** template and click **Create**.
4. In the **Start** node, click **Set Schedule** and specify the date, time, and frequency the flow should run. Nightly (off-hours) is the FQS-recommended cadence — RFM banding is stable and does not need intra-day refresh.
5. Click **Add Element** → **Action**.
6. In the **Category** section, select **Data Processing Engine**.
7. In the **Action** field, select the **RFM Score Calculation** data processing engine definition (the one you configured in Step 2).
8. Enter a label and API name for the action.
9. Enter a flow label, save, and **activate** the flow.

**Step 4 — Verify RFM scores are populating**

After the flow's first scheduled run:

1. From the App Launcher, open **Donor Gift Summaries** (or open a Person Account with historical gifts and view its related Donor Gift Summary).
2. Confirm the four scoring fields (`RecencyScore`, `FrequencyScore`, `MonetaryScore`, `CompositeRfmScore`) are populated.
3. Confirm the FQS-authored formula fields on Donor Gift Summary (`FQS_Is_Entry_Annual_Donor__c`, `FQS_Is_Mid_Annual_Donor__c`, `FQS_Is_Major_Annual_Donor__c`, and their Lifetime counterparts) evaluate correctly against your Donor Tier thresholds (§VIII).

If scores are all null after the scheduled run, check that:

* The Analytics Integration User has FQS Rollup DPE Read assigned (Step 1).
* The source object contains at least some non-null values in the source fields you selected.
* The scheduled flow ran successfully — from Setup → **Flows** → **Paused and Failed Flow Interviews**, verify no failures.

Supporting documentation:

* **Set Up RFM Scoring:** [Set Up Recency, Frequency, Monetary Value (RFM) Scoring in Nonprofit](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_set_up_rfm_scoring.htm&type=5)
* **Schedule the DPE:** [Create a Schedule-Triggered Flow to Run Data Processing Engine Jobs](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_create_schedule_triggered_flow_to_run_dpe_jobs.htm&type=5)
* **DPE Reference:** [Data Processing Engine Overview](https://help.salesforce.com/s/articleView?id=platform.data_processing_engine.htm&type=5)

### 7. Currency, Fiscal Year, and Multi-Entity Considerations

Nonprofit fundraising reporting almost always follows the organization's fiscal calendar rather than the calendar year — year-end appeals, board reporting, 990 preparation, and donor giving history all key off the fiscal year. Salesforce Fiscal Year settings are an org-wide decision, not an FQS toggle, but FQS reports and rollups inherit them, so it is worth a deliberate pass before you activate the accelerator against real data.

**When to configure fiscal year**

Configure fiscal year **before** loading historical gifts or building fundraising reports. Changing fiscal year settings after data is in flight recalculates existing forecasts, invalidates period-based automation, and can break saved report filters that reference "This Fiscal Year" / "Last Fiscal Year". If you inherited an org that already has fiscal year configured correctly, leave it alone.

**Standard vs. Custom Fiscal Year**

* **Standard Fiscal Year** — a 12-month fiscal year that starts on the first day of a month (e.g., July 1 – June 30, October 1 – September 30, January 1 – December 31). This is the right choice for the majority of nonprofits.
* **Custom Fiscal Year** — only if your organization uses a 4-4-5, 52/53-week, or other non-standard fiscal calendar.

*Notice: Once Custom Fiscal Year is enabled it cannot be disabled without Salesforce Support involvement. Confirm with your finance team before enabling.*

**Set the Fiscal Year Start Month (Standard Fiscal Year)**

1. From Setup, in the Quick Find box, enter **Fiscal Year**, and then select **Fiscal Year**.
2. Select **Standard Fiscal Year**.
3. Select the **Fiscal Year Start Month** that matches your organization's fiscal calendar (e.g., **July** for a July–June fiscal year).
4. Under **Fiscal Year Is Based On**, choose whether the fiscal year is named for the year in which it **starts** or **ends**. Confirm this with your finance team — GAAP-reporting nonprofits typically name the fiscal year for the year in which it **ends** (a July 2025 – June 2026 fiscal year is "FY2026").
5. Click **Save** and acknowledge the impact warning. Existing forecasts, quotas, and fiscal-year-based reports will be recalculated.

**Multi-currency and multi-entity**

FQS is authored against a single-currency, single-entity org. Multi-currency and multi-entity setups are supported by the underlying Nonprofit Cloud objects but are out of scope for this accelerator's ships-with automation and reports. If you run multi-currency: audit the FQS reports for hard-coded currency assumptions (`SUM(CurrentAmount)` rollups aggregate in the record's transaction currency; the FQS Donor Tiers dashboard does not switch presentation currency). If you run multi-entity (multiple business units in one org with data-sharing rules): re-scope the FQS Donor Tiers dashboard's Dynamic Dashboard `runningUser` per entity, and consider cloning the Custom Report Types (`fqs_*_Deluxe`) with entity-scoped filters before rolling out to end users.

Supporting documentation:

* [Set the Fiscal Year](https://help.salesforce.com/s/articleView?id=platform.admin_about_fiscal_years.htm&type=5)
* [Customize the Fiscal Year Structure](https://help.salesforce.com/s/articleView?id=platform.customize_fiscalyear.htm&type=5)
* [Define a Custom Fiscal Year](https://help.salesforce.com/s/articleView?id=platform.customize_fyf.htm&type=5)

### 8. Campaign Influence for Complex Major Gift Attribution

The `FQS_Fundraising` Campaign record type included in this accelerator works well for organizations that tie each Gift Transaction to a single campaign. However, major gift programs often involve multiple cultivation touchpoints — events, direct mail, personal visits, grant cycles — spread across several campaigns before a gift closes. A single Campaign lookup cannot represent this complexity.

**Campaign Influence** is Salesforce's native feature for multi-campaign attribution. It allows you to credit multiple campaigns for a single Opportunity (or Gift Transaction, when linked to an Opportunity) by distributing influence across the campaigns that touched the donor during the cultivation window. This is most relevant for:

* Major gift programs where relationship-building spans multiple fiscal years and many touchpoints
* Organizations that want to evaluate which campaign types (events, appeals, grants, personal outreach) generate the most major-gift revenue — not just which was the last campaign before close
* Development teams tracking ROI across a portfolio of campaigns rather than managing a single major-gifts campaign bucket

**Key concepts**

* **Campaign Influence records** are junction records between a Campaign and an Opportunity (via the Primary Campaign Source field or auto-association rules). Each record carries an influence percentage and a revenue amount so you can see what fraction of a gift is attributed to each campaign.
* **Primary Campaign Source** on the Opportunity remains the single "primary" campaign for simple reporting. Campaign Influence layers on top without replacing it.
* **Influence timeframe** controls how far back Salesforce looks for campaign member touchpoints when auto-associating campaigns to an opportunity. Set this to reflect your average cultivation window.
* **Customizable Campaign Influence** (the newer model) lets you define multiple influence models — for example, first-touch, last-touch, and even-distribution — so different stakeholders can view attribution through different lenses.

**Recommended approach for major gift programs**

Rather than creating one large "Major Gifts FY26" campaign and assigning all major gifts to it, consider:

1. Creating discrete `FQS_Fundraising` campaigns for each cultivation vehicle (Gala FY26, Fall Appeal, Leadership Dinner, Endowment Conversations).
2. Associating donors with the relevant campaigns as Campaign Members as they move through cultivation.
3. Enabling Campaign Influence so that when a major gift closes, credit is automatically distributed across the campaigns that touched the donor — giving your development team honest data on which activities drive major gift revenue.

*Notice: Campaign Influence auto-association requires that the Contact associated with the Gift Transaction / Opportunity also be a Campaign Member on the campaigns you want credited. Ensure your gift officers are logging campaign membership as part of their cultivation workflow, not just at the point of close.*

**Salesforce Documentation:**

* [Campaign Influence](https://help.salesforce.com/s/articleView?id=sales.campaign_influence_parent.htm&type=5)

### 9. How FQS Thinks About Gift Dates

FQS separates two ideas that many orgs blur together:

* **Transaction Date** — when the gift is fully in your hands and reconciled. Check cleared, card settled, wire received, stock sold, in-kind item taken in. This is your canonical "when did this gift happen" date and drives cash-flow reporting, aging, and rollups on the parent commitment.
* **Donor Tax Date** — when the gift left the donor's control for tax-receipt purposes. Postmark date for a mailed check, charge date for a card, delivery date for stock. This is the date on the donor's receipt for tax purposes.

Many orgs don't have a meaningful gap between the two — low volume, mostly card gifts, jurisdictions that treat receipt as the acknowledgement date. In those cases, leave **Donor Tax Date** blank and let **Transaction Date** speak for both. FQS's acknowledgement, stewardship, and tax-receipting flows use Transaction Date as the anchor.

**Other date fields on a gift**

* **Acknowledgement Date** — when the donor was thanked. Written automatically by the FQS Gift Acknowledgement flow.
* **Tax Receipt Date** — when the year-end tax receipt was issued. Manual field; managed by whatever year-end receipting process your org runs.
* **Stewardship Date** — when the follow-up stewardship touch was delivered. Written automatically by the FQS Stewardship Response flow.

### 10. Email Templates for Acknowledgement and Stewardship

FQS ships three plain-text email templates in a dedicated **FQS Templates** Classic email folder. They are sent by the FQS_Gift_Acknowledgement and FQS_Stewardship_Response scheduled flows.

* **FQS Gift Acknowledgement** — universal thank-you sent to every donor with a valid email. Uses standard 501(c)(3) tax-receipt language ("No goods or services were provided in exchange for this contribution").
* **FQS Gift Acknowledgement (Partial Deduction)** — sent when the deductible portion is less than the gift total (event tickets, benefit dinners, auction wins, in-kind gifts with variable cash-equivalence). The FQS_Gift_Acknowledgement flow routes to this template automatically when `TaxDeductionAmount < CurrentAmount`.
* **FQS Stewardship Response (Standard)** — sent T+14 days after acknowledgement to deepen the donor's connection to the mission. Not a fundraising ask — a bridge to the next gift.

**Treat these templates as a starting point.** Every organization has its own voice, mission, and audience. Personalize the templates from the record's activity pane — the Activity related list surfaces the sent email so you can see exactly what the donor received, then use that as the basis for a personal follow-up when the situation warrants it. The default copy is intentionally generic; edit it in **Setup → Email → Classic Email Templates → FQS Templates** before go-live.

Each template contains a `[PROVIDE SOME INFO ABOUT YOUR HISTORY, A SPECIFIC PROGRAM, PERSON, OR YOUR TOTAL IMPACT]` placeholder that must be replaced with mission-specific copy before the flows are activated.

**Important tax consideration.** The universal acknowledgement uses IRS-preferred "No goods or services" language, which is only correct when the donor received nothing of value in return. For event tickets, benefit dinners, auction wins, and membership gifts with tangible benefits, staff must set `TaxDeductionAmount` on the GiftTransaction to something less than `CurrentAmount` — that routes the flow to the Partial Deduction template. If staff enter these gifts with `TaxDeductionAmount` blank or equal to `CurrentAmount`, the donor will receive the wrong tax language. Train staff to enter FMV and non-deductible portions on non-standard gifts, and consider a periodic audit of high-benefit campaigns before year-end receipting.

**Optional: rebuild in Lightning Email Template Builder for drag-drop editing.** The templates ship as Classic text templates because Salesforce does not expose the "Made in Email Template Builder" flag to metadata deploys — templates authored outside the UI always install as plain HTML shells even when the underlying markup would otherwise render as blocks. If your admins want the drag-drop editing experience (add image blocks, buttons, column layouts, use the merge-field picker), recreate each template once, in the org, using the Builder:

1. **Setup → Email Templates** (the Lightning list, not Classic Email Templates).
2. **New Email Template** → pick the **FQS Templates** folder (or create a new Lightning folder if you prefer to keep the originals as fallback).
3. Copy the subject, body, and merge fields from the corresponding text template into the Builder. Set **Related Entity Type = Gift Transaction** so the flow can still find it by name.
4. Save with the same **API Name** as the original (e.g., `FQS_Gift_Acknowledgement`) so the flow's template lookup continues to resolve — Salesforce disambiguates by name across folders, so avoid creating duplicates in different folders with the same name.
5. Deactivate or delete the Classic version once the Builder version is confirmed working end-to-end (send a test through the flow).

This is a one-time, one-org exercise per template — the drag-drop editability is a client-side UI state that Salesforce does not persist through metadata deploys, so it cannot be committed back to source control for other orgs to inherit. Any org that wants Builder editing repeats these steps locally.

## Known Issues

* **Help text not visible in Related Record Detail components on Campaign flexipages** — The FQS Campaign record page uses Related Record Detail components to surface related record information inline. This is a platform limitation: Salesforce does not render field-level help text (the ⓘ tooltip icon) when a record is displayed through a Related Record Detail component — the icons are only visible on the record's own Lightning page. Admins who rely on help text to guide gift officers working from the Campaign page should consider supplementing with field descriptions visible in Object Manager, or moving guidance into an on-page rich text component.

* **Historical (last-year) campaigns from FQS Campaign Hierarchy Setup ship IsActive = false** — When the FQS Campaign Hierarchy Setup flow builds a Last-Year cohort, every campaign in that cohort (Strategic, Operational, Tactical) is created with `Status = Completed` **and** `IsActive = false`. This keeps default Campaign lookups uncluttered but means gift-entry pickers and Data Loader operations that filter on `IsActive = true` will not surface those campaigns. If you plan to backfill historical gift data against a last-year hierarchy, **temporarily set `IsActive = true` on the specific campaigns you'll be writing against before you import**, then flip them back after. The Seasonal / Strategy models also year-scope the rollup (e.g., "CY25 Fundraising"), so the entire tree — including the top-level rollup — is inactive by default; the GivingPrograms model reuses the same perpetual rollups (e.g., "Major Gifts") across years, so those rollups always stay active regardless of when they were first built.

* **FQS_Campaign_Category__c intentionally blank on rollup (Level 1) campaigns** — The FQS Campaign Hierarchy Setup flow leaves `FQS_Campaign_Category__c` blank on all Level 1 (Strategic) rollup campaigns. The field is only populated at Level 2 (Operational) and Level 3 (Tactical), where the semantic categorization (Major Gifts, Planned Giving, Events, Annual Giving, Grants, Corporate Match, In-Kind) actually applies to the underlying fundraising activity. If your team edits Level 1 campaigns manually, keep this field blank there as well — reserve `FQS_Campaign_Category__c` for Level 2/3 only. Reports and list-view filters that key off Category should exclude rollup rows via a hierarchy-depth filter (`FQS_Hierarchy_Depth__c IN (2, 3)`) or by excluding null Category.

## Backlog Items

The following items are on the roadmap for future FQS releases. They are not shipping in the current release; some depend on platform features that are themselves on the Nonprofit Cloud roadmap.

* **Corporate matching-gift screen flow** — the Apex layer for matching-gift orchestration (`FQS_MatchCandidateService` + `FQS_MatchCommitService`) ships along with `FQS_Match_Eligible__c` on `GiftCommitment`, but the front-end Find-Match screen flow (which surfaces eligible employers from Account Contact Relationships, creates the matching-gift `GiftCommitment` / `GiftTransaction` pair, and pairs it via `MatchingEmployerTransactionId`) is deferred. Post-1.0 scope may also add a matching-gift program lookup (`FQS_Matching_Gift_Program__c`, `FQS_Match_Ratio__c`, `FQS_Match_Annual_Individual_Maximum__c`) on the employer Account.

* **Soft credit automation** — possibly on the Nonprofit Cloud product roadmap. FQS will re-evaluate what to layer on top (auto-application from Account Contact Relationships / Contact Contact Relationships, household soft-credit defaults, tribute-driven soft credits) based on what the platform delivers natively.

* **OmniStudio Document Generation for tax receipting** — Nonprofit Cloud Fundraising ships native OmniStudio Document Generation templates for acknowledgement letters. FQS is scoped to extend those templates and orchestration for annual tax-receipting workflows (year-end aggregated receipts, per-gift receipts with FQS-specific fields like `FQS_Restriction_Release_Date__c` and split-designation breakdowns, and integration with the FQS stewardship flow).

* **Reporting — Community Asset Hub integration** — integrate the Salesforce Commons AFNP Best Practices — Community Asset Hub Fundraising reports (see [sfdo-community-sprints.github.io/npc-best-practices/fundraising/Reporting/](https://sfdo-community-sprints.github.io/npc-best-practices/fundraising/Reporting/)) alongside the FQS-authored reports and dashboards so admins have a broader library to adopt and extend without rebuilding from scratch.

* **Localization and Translation** — move hardcoded flow screen text, custom labels, and help-text strings to metadata labels to support future translation packs (Spanish and French are the two most-requested).

## Miscellaneous

### Revision History

<!-- TODO: update once the accelerator is published. Rough template: -->

0.1 (in development) — Initial build in progress. Not yet released. See commit history for scope in flight.

### Acknowledgements

Justin Gilmore — Architect

Specific thanks to:

* Jonathan Gillespie ([jongpie](https://github.com/jongpie)) — the `FQS_CustomMetadataSaver` Apex class that lets the FQS Setup Flow write Custom Metadata Type records is adapted from his MIT-licensed [CustomMetadataSaver](https://github.com/jongpie/CustomMetadataSaver) project.

<!-- TODO: fill in contributor list as beta testing, review, and documentation help materializes.
* [Name] — For contributions related to [feature]
* [Name] — For testing
* [Name] — For reviewing text and documentation
-->

### Terms of Use

Thank you for using Global Public Sector (GPS) Accelerators. Accelerators are provided by Salesforce.com, Inc., located at 1 Market Street, San Francisco, CA 94105, United States.

By using this site and these accelerators, you are agreeing to these terms. Please read them carefully.

Accelerators are not supported by Salesforce, they are supplied as-is, and are meant to be a starting point for your organization. Salesforce is not liable for the use of accelerators.

For more about the Accelerator program, visit: https://gpsaccelerators.developer.salesforce.com/
