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

3. **Enable Nonprofit Cloud Fundraising**
   1. In Setup, search for **Fundraising**, and select **Fundraising Settings**.
   2. Turn on **Fundraising Tools for Everyone**.
   3. <!-- TODO: any additional Fundraising Settings toggles required (recurring gifts, tributes, matching, refunds) -->

4. **Assign the Fundraising_Admin Permission Set Group**
   1. From Setup, in the Quick Find box, enter **Permission Set Groups**, and then select **Permission Set Groups**.
   2. Click **Recently Viewed** and then select **All Permission Set Groups**.
   3. Click the permission set group name **Fundraising_Admin** in the list view.
   4. Click **Manage Assignments** and then **Add Assignments**.
   5. Select each user to whom you want to assign the group, and then click **Next**.
   6. Optionally, select an expiration date for the user assignment to expire.
   7. Click **Assign**.

5. **Enable Person Accounts for Fundraising** (only if not already enabled via Stakeholder Management Quick Start)
   1. <!-- TODO: reference SMQS steps or link to sfdo.fundraising_enable_person_accounts_for_fundraising.htm -->

6. **Enable Multiple Address Management** (only if not already enabled via Stakeholder Management Quick Start)
   1. <!-- TODO: cross-reference SMQS or provide standalone steps -->

7. **Enable Data Protection and Privacy** (only if not already enabled via Stakeholder Management Quick Start)
   1. <!-- TODO: cross-reference SMQS or provide standalone steps -->

8. **Plan Your Field History Tracking Strategy**

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

9. **Enable Contacts to Multiple Accounts**
   1. From Setup, enter **Account Settings** in the Quick Find box, and then select **Account Settings**.

      Note: Only users with the Customize Application permission can view or edit Account Settings.

   2. Click **Edit**.
   3. Select **Allow users to relate a contact to multiple accounts** and click **Save**.
   4. When the Contacts to Multiple Accounts Settings section appears, review the default options and save your changes.

8. <!-- TODO: any additional pre-install setting (payment gateway config, currency setup) that FQS depends on -->

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

<!-- TODO: enumerate any remaining UI, currency, or Fundraising-specific settings that must be toggled after install. Candidates:
* Multi-currency (if in scope)
* Advanced Currency Management
* Recurring Gift settings
* Gift Matching settings
* Gift Refund / Adjustment settings
-->

1. **Configure Fiscal Year**

   Nonprofit fundraising reporting almost always follows the organization's fiscal calendar rather than the calendar year (year-end appeals, board reporting, 990 preparation, and donor giving history all key off the fiscal year). Configure this **before** loading historical gifts or building fundraising reports — changing fiscal year settings after the fact can invalidate existing reports, forecasts, and period-based automation.

   1. **Decide between Standard and Custom Fiscal Year**
      1. Choose **Standard Fiscal Year** if your organization uses a 12-month fiscal year that starts on the first day of a month (e.g., July 1 – June 30, October 1 – September 30, January 1 – December 31). This is the right choice for the majority of nonprofits.
      2. Choose **Custom Fiscal Year** only if your organization uses a 4-4-5, 52/53-week, or other non-standard fiscal calendar. <!-- TODO: link internal guidance for orgs on custom fiscal years -->

      *Notice: Once Custom Fiscal Year is enabled it cannot be disabled without Salesforce Support involvement. Confirm with your finance team before enabling.*

   2. **Set the Fiscal Year Start Month (Standard Fiscal Year)**
      1. From Setup, in the Quick Find box, enter **Fiscal Year**, and then select **Fiscal Year**.
      2. Select **Standard Fiscal Year**.
      3. Select the **Fiscal Year Start Month** that matches your organization's fiscal calendar (e.g., **July** for a July–June fiscal year).
      4. Under **Fiscal Year Is Based On**, choose whether the fiscal year is named for the year in which it **starts** or **ends**. Confirm this with your finance team — GAAP-reporting nonprofits typically name the fiscal year for the year in which it **ends** (a July 2025 – June 2026 fiscal year is "FY2026").
      5. Click **Save**.
      6. Acknowledge the impact warning. Existing forecasts, quotas, and fiscal-year-based reports will be recalculated.

   3. **Verify Fiscal Year on Gift Transaction Reporting**
      1. Open the **Fundraising Quick Start** app and navigate to a Gift Transaction record with a Close Date in the current fiscal year.
      2. Confirm that standard fiscal-year-based report filters (e.g., "This Fiscal Year", "Current and Previous Fiscal Year") return the expected gifts.
      3. <!-- TODO: reference the specific FQS reports / dashboards that key off fiscal year once built -->

   Supporting documentation:

   * [Set the Fiscal Year](https://help.salesforce.com/s/articleView?id=platform.admin_about_fiscal_years.htm&type=5)
   * [Customize the Fiscal Year Structure](https://help.salesforce.com/s/articleView?id=platform.customize_fiscalyear.htm&type=5)
   * [Define a Custom Fiscal Year](https://help.salesforce.com/s/articleView?id=platform.customize_fyf.htm&type=5)

2. **Enable Field History Tracking**

   Complete the fields you identified in the pre-install planning step (Before You Install, step 7) for each object. The steps below cover Campaign (package-deployed with history enabled but no fields selected), Opportunity (package-deployed with history disabled), and the Salesforce-managed Fundraising objects.

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

3. **Create and Configure an Org-Wide Email Address for Donor Acknowledgements**

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

**II. Set Up the Automation App and Create a Flows List View**

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
   2. The **FQS Gift Acknowledgement** flow will appear **Inactive** here — this is expected. Activate it only after completing section VIII.
   3. All other FQS flows should be **Active** after package installation. If any show as Inactive or Invalid Draft, investigate before going live.

**III. Assign Permission Sets**

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

<!-- TODO: add additional FQS-specific permission sets as they are built out
3. **Assign the FQS Gift Entry Permission Set**
4. **Assign the FQS Gift Refunds Permission Set**
5. **Assign the FQS Donor Summary Permission Set**
-->

**IV. Configure Gift Transaction and Gift Commitment Access**

<!-- TODO: fill out with the concrete profile / permission-set / page-layout / record-type assignments that need to happen. Rough shape:
1. Provide access to the FQS Fundraising Campaign Record Type
2. Modify Gift Transaction Page Layouts (assign SMQS-equivalent FQS layouts)
3. Modify Gift Commitment Page Layouts
4. Modify Search Layouts on Gift Transaction and Gift Commitment
5. Modify List View Button Layouts on Gift Transaction and Gift Commitment
-->

1. **Add the leaf-Campaign lookup filter to Gift Transaction**

   `GiftTransaction.CampaignId` is a Nonprofit Cloud–owned standard field. Salesforce does not include lookup-filter edits to standard fields in unmanaged packages, so this step must be applied manually in every install. The filter steers users to attribute each gift to a level-3 (ask) Campaign — the concrete solicitation — rather than a level-1 rollup or level-2 strategy. Ask-level attribution keeps performance reports honest; rollup-level attribution hides the ask from the numbers you were trying to measure.

   The filter uses `FQS_Hierarchy_Depth__c` on Campaign — a formula field the package installs (1 = top rollup, 2 = strategy, 3 = ask, up to 5 levels). It ships as **Optional** so users can override for exceptions (e.g., a gift attributed to an evergreen program rollup with no ask-level campaign yet).

   1. From Setup, click the **Object Manager** tab.
   2. Search for and click **Gift Transaction**, then select **Fields & Relationships**.
   3. Click the field **Campaign**.
   4. Scroll down to **Lookup Filter** and click **Edit**.
   5. Select **Show only records that match the filter criteria (Optional)**.
   6. Add the following filter criterion:
      * **Field:** Campaign: Hierarchy Depth
      * **Operator:** greater or equal
      * **Value:** 3
   7. In the **Info Message** field, enter: *FQS reporting expects gifts to be attributed to a level-3 (ask) campaign or deeper. Higher levels are rollups.*
   8. In the **Error Message** field, enter: *Pick a leaf-level Campaign (the actual ask). Rollups and strategies are for reporting only — attributing a gift there hides it from ask-level performance reports.*
   9. Confirm **Filter Type** is **Optional** (matches the FQS convention — users see the warning and can uncheck **Filter by:** in the picker to select a rollup when a legitimate exception exists).
   10. Click **Save**.

2. **Add the leaf-Campaign lookup filter to Gift Commitment**

   Apply the same lookup-filter pattern to `GiftCommitment.CampaignId`. Same rationale, same standard-field caveat.

   1. From Setup, click the **Object Manager** tab.
   2. Search for and click **Gift Commitment**, then select **Fields & Relationships**.
   3. Click the field **Campaign**.
   4. Scroll down to **Lookup Filter** and click **Edit**.
   5. Select **Show only records that match the filter criteria (Optional)**.
   6. Add the following filter criterion:
      * **Field:** Campaign: Hierarchy Depth
      * **Operator:** greater or equal
      * **Value:** 3
   7. In the **Info Message** field, enter: *FQS reporting expects commitments to be attributed to a level-3 (ask) campaign or deeper. Higher levels are rollups.*
   8. In the **Error Message** field, enter: *Pick a leaf-level Campaign (the actual ask). Rollups and strategies are for reporting only — attributing a commitment there hides it from ask-level performance reports.*
   9. Confirm **Filter Type** is **Optional**.
   10. Click **Save**.

3. **Add help text to Gift Commitment: Effective Start Date**

   `GiftCommitment.EffectiveStartDate` is a Nonprofit Cloud–owned standard field. Salesforce does not include help-text edits to standard fields in unmanaged packages, so this step must be applied manually in every install. Documenting the field on the record prevents a common data-entry mistake: end users assume this is the date the first payment posts, when it is actually the date the donor formally committed (signed the pledge or grant letter). Those two dates can differ by weeks or months.

   1. From Setup, click the **Object Manager** tab.
   2. Search for and click **Gift Commitment**, then select **Fields & Relationships**.
   3. Click the field **Effective Start Date**.
   4. Click **Edit**.
   5. In the **Help Text** field, enter: *The date the donor formally committed to this gift (signed the pledge or grant letter). This can be earlier than when the first payment arrives.*
   6. Click **Save**.

4. **Add help text to Gift Commitment Schedule: Start Date**

   `GiftCommitmentSchedule.StartDate` is a Nonprofit Cloud–owned standard field. Documenting it clarifies the split between the signing date on the parent commitment (Effective Start Date) and the first-payment date on the schedule — a common source of manual-entry confusion. It also flags the platform activation gate: Salesforce back-fills the parent commitment's Current Gift Commitment Schedule, Next Transaction Date, and Last Paid Transaction Date only when Start Date is on or before today.

   1. From Setup, click the **Object Manager** tab.
   2. Search for and click **Gift Commitment Schedule**, then select **Fields & Relationships**.
   3. Click the field **Start Date**.
   4. Click **Edit**.
   5. In the **Help Text** field, enter: *The date the first scheduled payment is expected. This can be later than the signing date on the parent commitment. The schedule stays inactive until this date is on or before today.*
   6. Click **Save**.

5. **Add help text to Gift Transaction: Transaction Date**

   `GiftTransaction.TransactionDate` (Transaction Completion Date) is a Nonprofit Cloud–owned standard field. FQS treats it as the canonical "when did this gift happen" date — the date the gift is fully in the org's hands and reconciled (check cleared, card settled, wire received, stock sold, in-kind item taken into custody). Documenting the field on the record heads off the most common misuse: end users default to entering the donor's mailing / signing / postmark date, which belongs on the separate `FQS_Donor_Tax_Date__c` field. FQS's cash-flow reporting, aging, and rollups all anchor to Transaction Date; getting it wrong misstates when the org actually received the funds.

   1. From Setup, click the **Object Manager** tab.
   2. Search for and click **Gift Transaction**, then select **Fields & Relationships**.
   3. Click the field **Transaction Date**.
   4. Click **Edit**.
   5. In the **Help Text** field, enter: *When the org fully received and reconciled the gift — check cleared, card settled, wire received. If you also track when the donor sent the gift (postmark, charge date), use Donor Tax Date. Required when Status is Paid or Fully Refunded.*
   6. Click **Save**.

6. **Add help text to Gift Transaction: Acknowledgement Date**

   `GiftTransaction.AcknowledgementDate` is a Nonprofit Cloud–owned standard field. FQS writes it automatically from the Gift Acknowledgement flow when the thank-you is delivered — end users normally do not set it by hand. Documenting the field prevents confusion with two adjacent dates: `FQS_Donor_Tax_Date__c` (when the gift left the donor's control for tax-receipt purposes — postmark for checks, delivery for stock) and `FQS_Tax_Receipt_Date__c` (when the year-end tax receipt was issued).

   1. From Setup, click the **Object Manager** tab.
   2. Search for and click **Gift Transaction**, then select **Fields & Relationships**.
   3. Click the field **Acknowledgement Date**.
   4. Click **Edit**.
   5. In the **Help Text** field, enter: *When this donor was thanked for the gift. Usually set automatically by the FQS Gift Acknowledgement flow when the thank-you goes out. Not the tax receipt date and not the donor tax date.*
   6. Click **Save**.

7. **Add help text to Gift Transaction: Payment Identifier**

   `GiftTransaction.PaymentIdentifier` is a Nonprofit Cloud–owned standard field. FQS surfaces it on the Gift Entry Gift Details screen, conditionally shown when the payment method is Check or ACH so the user can capture the reference that ties the gift to the bank record. The default label ("Payment Identifier") doesn't tell a data-entry user what to actually type — the help text disambiguates.

   1. From Setup, click the **Object Manager** tab.
   2. Search for and click **Gift Transaction**, then select **Fields & Relationships**.
   3. Click the field **Payment Identifier**.
   4. Click **Edit**.
   5. In the **Help Text** field, enter: *Check Number of Bank Account Name*
   6. Click **Save**.

**V. Configure Designation, Soft Credit, and Tribute Objects**

<!-- TODO: still to fill in:
1. Modify the Gift Designation Object (picklist cleanup on FQS_Restriction_Type__c, IsActive default, help text)
4. Modify the Gift Soft Credit Object
5. Modify the Gift Default Soft Credit Object
6. Modify the Gift Tribute Object
-->

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

2. **Add the Active-Designation lookup filter to the Gift Default Designation object**

   By default, the **Designation** lookup on the Gift Default Designation object lets users pick any Gift Designation, including designations that have been retired (`IsActive = false`). Left as-is, this makes it easy for users to attach a payment schedule to a designation the finance team has explicitly closed. Add a lookup filter that restricts the picker to active designations, while still allowing users to override the filter when there is a legitimate reason (e.g., a back-dated correction to a retired designation).

   1. From Setup, click the **Object Manager** tab.
   2. Click the object name **Gift Default Designation**.
   3. Click **Fields & Relationships**, then click the field **Designation**.
   4. Scroll down to **Lookup Filter** and click **Edit**.
   5. Select **Show only records that match the filter criteria (Optional)**. This is the key setting — it activates the filter but leaves an *"Show all results"* toggle in the picker so users can still bypass the filter and select a retired designation when needed.
   6. Add the following filter criterion:
      * **Field:** Gift Designation: Active
      * **Operator:** equals
      * **Value:** True
   7. Under **Filter Type**, confirm the filter is set to **Required** *only if* you want to block all inactive-designation selections outright. FQS ships this filter as **Optional** so that users can override in edge cases; changing to **Required** removes the override.
   8. In the **Error Message** field, enter: *This is not an active Gift Designation. Uncheck the "Filter by:" checkbox in the lookup dialog to see all designations, including inactive ones.*
   9. Click **Save**.

   *Notice: This differs from the Stakeholder Management Quick Start convention, which uses a Required filter on similar lookups. FQS deliberately allows the override to accommodate finance corrections against retired designations.*

3. **Add the Active-Designation lookup filter to the Gift Transaction Designation object**

   Apply the same lookup-filter pattern to the **Designation** lookup on the Gift Transaction Designation object. This keeps runtime gift entry against a curated list of active designations while preserving the ability to override for corrections and back-dated adjustments.

   1. From Setup, click the **Object Manager** tab.
   2. Click the object name **Gift Transaction Designation**.
   3. Click **Fields & Relationships**, then click the field **Designation**.
   4. Scroll down to **Lookup Filter** and click **Edit**.
   5. Select **Show only records that match the filter criteria (Optional)**.
   6. Add the following filter criterion:
      * **Field:** Gift Designation: Active
      * **Operator:** equals
      * **Value:** True
   7. Confirm **Filter Type** is **Optional** (matches the FQS convention on Gift Default Designation).
   8. In the **Error Message** field, enter: *This is not an active Gift Designation. Uncheck the "Filter by:" checkbox in the lookup dialog to see all designations, including inactive ones.*
   9. Click **Save**.

**VI. Configure Refunds, Payment Instruments, and Outreach**

<!-- TODO: fill out with the steps to enable Gift Refunds and wire up Outreach Source Code / Outreach Summary. Candidates:
1. Modify the Gift Refund Object (lookup filters, help text, page layout)
2. Modify the Payment Instrument Object (record types, page layout)
3. Modify Outreach Source Code and Outreach Summary picklists
-->

**VII. Configure Outreach Source Code Auto-Generation**

FQS ships with **automatic default Outreach Source Code creation** for every Tactical (Level 3+) campaign. One default OSC is created per tactical campaign so that gifts logged against the campaign can be attributed immediately without waiting for someone to hand-author source codes. Users are expected to **clone the default** to add channel variants (a second OSC for social paid, a third for direct mail, etc.).

The auto-creation runs in two paths:

1. **During FQS Campaign Hierarchy Setup** — after the hierarchy builder inserts the Level 3 tacticals, `FQS_OutreachSourceCodeBuilder.buildDefaultsForCampaigns()` fires and inserts one OSC per tactical, then flips **Create Default Outreach Sources** to true on each Ask as an audit flag. The Final screen shows the count.
2. **Manually per-campaign** — check the **Create Default Outreach Sources** checkbox on any Tactical campaign; the `FQS_Campaign_Create_Default_OSCs` record-triggered flow calls the same service. Idempotent — safe to re-check if the earlier OSC was deleted. The checkbox stays checked afterward as a persistent audit flag.

The default OSC is populated as follows:

| OSC field | Value |
|---|---|
| `Name` | `{Campaign.Name} — {ChannelLabel}` |
| `SourceCode` | Auto-generated slug: `{ShortSlug}-{YY}-{ChannelCode}` (e.g. `FY26-YEAREND-EMAIL-26-EM`). `ShortSlug` = uppercased `Campaign.FQS_Short_Name__c` when populated; hierarchy builder derives `Short Name` from the template key (e.g. `fy26-yearend-email`). Word-based fallback (first 4 of word 1 + first 2 of word 2) applies only when Short Name is blank. If **Outreach Source Code Auto-Generation** (below) is enabled in Setup, that formula overrides this default at save. |
| `CampaignId` | Parent tactical campaign |
| `Status` | `Active` when `Campaign.IsActive = true`, else `Inactive` |
| `UsageType` | `Fundraising` |
| `MessageChannel` | Derived from `FQS_Campaign_Category__c` — see mapping below |
| `FQS_Platform__c` | Derived from `FQS_Campaign_Category__c` — see mapping below |
| `FQS_Message_Channel_Segment__c` | Auto-derived formula field (Organic / Paid Digital / Owned or Acquired Lists) |
| `External_Id__c` | `FQS-OSC-{CampaignId15}-DEFAULT` — unique key that guarantees one default per campaign |

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

These defaults are the low-friction starting point. Users clone the default OSC to model additional channels per campaign; the formula-based auto-generation described below still governs the `SourceCode` value on the cloned records.

---

Beyond the FQS defaults, Salesforce Fundraising can automatically generate a standardized `SourceCode` value on each Outreach Source Code record based on a formula you define. This keeps your source codes consistent and machine-readable without relying on gift officers to type them manually.

The FQS convention maps UTM parameters to the Outreach Source Code data model as follows, using the FQS formula: `{FQS_Platform__c} + {MessageChannel} + {Campaign.FQS_Short_Name__c}`

| UTM Parameter | Maps to object | Maps to field | Why |
|---|---|---|---|
| UTM Source | Outreach Source Code | `FQS_Platform__c` (Platform) | The specific platform or source within a channel (e.g., `Instagram`, `mailchimp`, `google`) |
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
      {FQS_Platform__c} + {MessageChannel} + {Campaign.FQS_Short_Name__c}
      ```
   2. Add each token by selecting it from the reference fields panel rather than typing it manually — this ensures the syntax is valid.
   3. The `+` operator concatenates the three values with no separator. If you want a delimiter between segments (e.g., a hyphen), add a string literal between them: `{FQS_Platform__c} + "-" + {MessageChannel} + "-" + {Campaign.FQS_Short_Name__c}`.

5. **Validate and save**
   1. Click **Validate Syntax** to confirm the formula is valid. Fix any errors before proceeding.
   2. Click **Save**.

Once saved, Salesforce will auto-populate the `SourceCode` field on new Outreach Source Code records according to this formula. For example, an Email Outreach Source Code with Platform `mailchimp` linked to a Campaign with Short Name `fy26-yearend` would generate `mailchimpEmailfy26-yearend` — adjust delimiter literals in the formula to produce the format your team needs.

*Notice: The formula acts on the values in `FQS_Platform__c`, `MessageChannel`, and `FQS_Short_Name__c` at the time the Outreach Source Code record is saved. If any of those values are blank, that segment of the generated code will be blank. Ensure the Campaign Short Name is populated before creating Outreach Source Codes against a campaign, and that Platform is filled in on each Outreach Source Code record.*

Supporting documentation:

* [Set Up Outreach Source Codes](https://help.salesforce.com/s/articleView?id=sfdo.fundraising_set_up_outreach_source_codes.htm&type=5)

---

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

2. **Review and customize the email content** — The flow sends a plain-text email. The body is built by a formula resource named `frmEmailBody` inside the flow — **not** by a referenced email template. A companion shell template (`FQS_Gift_Acknowledgement`) is included in the package for reference, but the live email text comes from the formula. To customize it:
   1. Open the flow in **Flow Builder** (Setup → Flows → FQS Gift Acknowledgement).
   2. In the **Toolbox** panel on the left, click **Formulas**.
   3. Click **frmEmailBody** to open and edit the formula.
   4. The default formula already merges in: the donor's salutation and first name, `CurrentAmount`, `TransactionDate`, `TaxDeductionAmount`, and `$Organization.Name`. Confirm these fields resolve correctly for your gift entry process before going live.
   5. Replace the `[Placeholder copy — replace before go-live.]` line with your organization's actual acknowledgement language. Add your organization's EIN, mailing address, and any legally required tax-receipt language for your jurisdiction.
   6. Update the email subject if needed. The subject (`"Thank you for your gift!"`) is set directly on the **Send Acknowledgement Email** action element — find it on the flow canvas to edit it.
   7. You can also review the shell template text at [force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement.email](force-app/main/default/email/unfiled$public/FQS_Gift_Acknowledgement.email) as a plain-text reference, but editing that file does not change what the flow sends — only editing the `frmEmailBody` formula does.

3. **Verify the FQS Gift Acknowledgements queue exists** — Gifts routed to **Exclude All** or **Exclude Lifetime** (lifetime escalation) create Tasks owned by this queue. Confirm the queue exists and has the right members before activating.
   1. From **Setup**, in the **Quick Find** box, enter **Queues**, and then select **Queues**.
   2. Confirm **FQS Gift Acknowledgements** is listed.
   3. Click the queue name and verify the **Queue Members** list includes the appropriate gift officers or development staff.

4. **Verify `FQS_Is_Major_Gift__c` and `FQS_Is_Mid_Gift__c` are being populated** — The flow's tier-resolution logic reads these checkbox fields on the Gift Transaction. If they are not being set by your gift entry process or a classification flow, the flow will default every gift to the `Entry` donor tier. Confirm how these fields are populated in your org before activating.

5. **Test in a sandbox** — Create a test Gift Transaction, set its status to `Paid`, and verify the 3-day scheduled path fires correctly and routes to the expected email or Task.

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

**X. Configure App Access**

1. **Change Access to Lightning Apps**
   1. From Setup, in the Quick Find box, enter 'App Manager', and then select **App Manager**.
   2. Click the icon on the **Fundraising Quick Start** app's row, and select **Edit**.
   3. Under 'App Settings', click on **User Profiles**.
   4. Select the appropriate Profiles in the **Available Profiles** column and move to **Selected Profiles**.
   5. Click **Save**.

2. **Navigate to Fundraising Quick Start**
   1. Click the **App Launcher** icon (nine dots) on the far left of the top navigation bar.
   2. Select **Fundraising Quick Start**. If unavailable use the **Search apps and items** box.

## Post-Install Considerations: Making This Work For You In Your Existing Setup

While this package installs a standalone custom app, it is highly likely that your fundraising operation is already entangled with other processes across your organization (stakeholder management, programs, grants, case management, marketing). Rather than forcing users to switch between disconnected apps, **the goal of this post-install process is to adopt and integrate these new components—the modular flows, custom fields, dynamic pages, and record types—into your primary, existing business apps.** Use the following steps to review, adjust, and embed the accelerator into your live environment.

### 1. Review Component Configurations via the Home Page

<!-- TODO: describe the Fundraising Quick Start home page and any guided setup flows that live on it. Placeholder structure below mirrors the SMQS pattern. -->

The homepage of the Fundraising Quick Start Lightning App serves as your starting point for learning and mastering the various components of the package. Review the page and follow the guidance to complete the setup.

* **1a. Gift Transactions and Commitments:**
  * <!-- TODO: describe any guided flow / setup component on the home page related to gift entry and recurring commitments -->
* **1b. Designations and Restrictions:**
  * <!-- TODO: describe designation setup guidance, including how to align FQS_Restriction_Type__c values with the org's chart of accounts -->
* **1c. Soft Credits and Tributes:**
  * <!-- TODO: describe soft credit / tribute setup considerations -->
* **1d. Refunds and Adjustments:**
  * <!-- TODO: describe the refund workflow and how to keep totals accurate -->
* **1e. Outreach Attribution:**
  * <!-- TODO: describe how Outreach Source Code and Outreach Summary connect to Gift Transaction for appeal reporting -->

**Flow Resources:**

* **Introductory Guide:** [What Is a Screen Flow?](https://admin.salesforce.com/blog/2023/what-is-a-screen-flow)
* **Process Automation:** [Extend Salesforce with Click-Not-Code Processes](https://help.salesforce.com/s/articleView?id=sf.extend_click_process.htm&type=5)
* **Core Documentation:** [Platform Automation Overview](https://help.salesforce.com/s/articleView?id=platform.platform_automation.htm&type=5)
* **Trailhead Trail:** [Build Flows with Flow Builder](https://trailhead.salesforce.com/content/learn/trails/build-flows-with-flow-builder)

### 2. Review Agentforce Nonprofit / Nonprofit Cloud Fundraising Setup Steps

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

### 3. Review Profiles and Permission Sets

The package does not include rigid, pre-packaged permission sets for field, object, and flow access. You will need to design your own access strategy based on your data governance model:

* **Determine Data Entry Paths:** Decide how and where your users will enter gifts (Gift Entry, Gift Batch, direct object creation, integrated payment processors) and design permission sets to remove options that will not be supported.
* **Segregate Duties:** Gift entry, gift adjustment/refund, and gift acknowledgement are commonly done by different people. Consider building permission sets that map cleanly to those duties rather than granting blanket access to the Fundraising object family.
* **Build Custom Permission Sets and Groups:** The accelerator includes a basic **FQS Custom Fields** permission set for you to adopt and merge with your own custom permission sets and groups.

**Salesforce Documentation:**

* **Core Guide:** [Permission Sets Overview](https://help.salesforce.com/s/articleView?id=platform.perm_sets_overview.htm&language=en_US&type=5)
* **Assignment Guide:** [Manage Permission Set Assignments](https://help.salesforce.com/s/articleView?id=platform.perm_sets_manage_assignments.htm&language=en_US&type=5)
* **Best Practices:** [Guidelines for Creating Permission Sets and Permission Set Groups](https://help.salesforce.com/s/articleView?id=platform.perm_sets_best_practices.htm&language=en_US&type=5)

### 4. Review Lightning Apps, Pages, and Page Layouts

To deliver a seamless user experience, transition the components from the standalone package app into your primary operational apps:

**Migrate Dynamic Pages:** Review the dynamic Lightning record pages provided by the package for Gift Transaction, Gift Commitment, Gift Designation, Gift Refund, Gift Tribute, Donor Gift Summary, Outreach Source Code, Outreach Summary, Payment Instrument, Campaign, and Opportunity. Instead of using the default standalone app layout, use the Lightning App Builder to assign these dynamic pages (or migrate their conditional visibility components) to your organization's primary working apps.

**Consolidate Page Layouts:** Audit your existing Gift Transaction and Gift Commitment page layouts to embed the custom fields (like `FQS_Gift_Transaction_Category__c`, `FQS_In_Kind__c`, `FQS_Matched__c`, `FQS_Recurring__c`, `FQS_Restriction_Type__c`) and replace standard related lists with the package's modular components where appropriate.

**Salesforce Documentation:**

* **Guide:** [Break Up Your Record Details with Dynamic Forms](https://help.salesforce.com/s/articleView?id=platform.dynamic_forms_overview.htm&language=en_US&type=5)
* **Access Control:** [Assign Record Types and Page Layouts in Profiles](https://help.salesforce.com/s/articleView?id=platform.users_profiles_record_types.htm&type=5)
* **Trailhead Module:** [Lightning App Builder](https://trailhead.salesforce.com/content/learn/modules/lightning_app_builder)

### 5. Establish Data Integrity Guardrails

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

**Build an Automation Bypass:** <!-- TODO: describe the recommended bypass pattern once flows are finalized. Candidate: add a Bypass_Automation__c checkbox to flow entry criteria to short-circuit sync flows during bulk data loads. -->

**Salesforce Documentation:**

* **Validation Rules Guide:** [Validation Rules Documentation](https://help.salesforce.com/s/articleView?id=platform.fields_about_field_validation.htm&language=en_US&type=5)
* **Duplicate Rules Guide:** [Duplicate Rules Map of Reference](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_map_of_reference.htm&type=5)
* **Duplicate Rules Framework:** [Things to Know About Duplicate Rules](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_overview.htm&type=5)
* **Standard OOTB Rules:** [Standard Duplicate Rules Reference](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_standard_rules.htm&type=5)

### 6. Reporting and Dashboards

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
* **FQS Campaign Performance By Depth** — Summary report of paid-gift totals grouped by `Campaign.FQS_Hierarchy_Depth__c` (1 = rollup, 5 = leaf). Validates that the optional lookup filter shipped on `GiftTransaction.CampaignId` and `GiftCommitment.CampaignId` (see Post-Install steps IV and V) is being honored — depth-3 (ask-level) attribution should dominate healthy data. If most gifts land on depth 1 or 2, users are attributing to rollups and reporting is being skewed.

**Dashboard (`force-app/main/default/dashboards/FQSDashboards/`):**

* **FQS Donor Tiers** — eight-component dashboard pairing the reports above. Runs as **Dynamic Dashboard** (`dashboardType = LoggedInUser`), so each viewer sees data scoped to their own record access rather than a fixed running user. This costs one Dynamic Dashboard license slot per subscriber org (Enterprise Edition includes five; Unlimited includes ten) but avoids the tenant-specific `runningUser` problem that would otherwise force each installing admin to re-point the dashboard at their own user. If your org has already exhausted its Dynamic Dashboard allocation, edit the dashboard to `SpecifiedUser` and point `runningUser` at a service-style admin user with read access to the full donor set.

**Adopt or extend:**

* All seven reports live in the shared **FQS Donor Tier Reports** folder with `Shared` access and `ReadWrite` public-folder access — change this to match your access model.
* The lookup filters on `GiftTransaction.CampaignId` and `GiftCommitment.CampaignId` are shipped as `isOptional = true` (warn only, users can bypass). Consider tightening to `isOptional = false` if you want to hard-enforce ask-level attribution — see Post-Install steps IV.1 and V.3 for the click-path.
* Deferred future additions the seed already supports but which need policy decisions from your org first: **recurring giving retention** (needs a rolling snapshot policy), **refund and adjustment audit** (needs your refund-reason taxonomy), **outreach source-code attribution** (needs your UTM / channel definitions locked in), and **restriction-type breakdown of committed revenue** (needs your finance team's chart-of-accounts mapping to `FQS_Restriction_Type__c` locked in — see Section 5 above).

**Salesforce Documentation:**

* **Guide:** [Reports and Dashboards Overview](https://help.salesforce.com/s/articleView?id=platform.reports_dashboards.htm&type=5)
* **Custom Report Types:** [Set Up a Custom Report Type](https://help.salesforce.com/s/articleView?id=platform.reports_report_types.htm&type=5)
* **Dynamic Dashboards:** [Set Up Dynamic Dashboards](https://help.salesforce.com/s/articleView?id=platform.dashboards_dynamic_setup.htm&type=5)

### 7. Currency, Fiscal Year, and Multi-Entity Considerations

<!-- TODO: describe how this accelerator behaves under multi-currency, custom fiscal years, and multi-entity setups. Note anything that is out of scope. -->

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

## Known Issues

* **Help text not visible in Related Record Detail components on Campaign flexipages** — The FQS Campaign record page uses Related Record Detail components to surface related record information inline. This is a platform limitation: Salesforce does not render field-level help text (the ⓘ tooltip icon) when a record is displayed through a Related Record Detail component — the icons are only visible on the record's own Lightning page. Admins who rely on help text to guide gift officers working from the Campaign page should consider supplementing with field descriptions visible in Object Manager, or moving guidance into an on-page rich text component.

* **Historical (last-year) campaigns from FQS Campaign Hierarchy Setup ship IsActive = false** — When the FQS Campaign Hierarchy Setup flow builds a Last-Year cohort, every campaign in that cohort (Strategic, Operational, Tactical) is created with `Status = Completed` **and** `IsActive = false`. This keeps default Campaign lookups uncluttered but means gift-entry pickers and Data Loader operations that filter on `IsActive = true` will not surface those campaigns. If you plan to backfill historical gift data against a last-year hierarchy, **temporarily set `IsActive = true` on the specific campaigns you'll be writing against before you import**, then flip them back after. The Seasonal / Strategy models also year-scope the rollup (e.g., "CY25 Fundraising"), so the entire tree — including the top-level rollup — is inactive by default; the GivingPrograms model reuses the same perpetual rollups (e.g., "Major Gifts") across years, so those rollups always stay active regardless of when they were first built.

* **FQS_Campaign_Category__c intentionally blank on rollup (Level 1) campaigns** — The FQS Campaign Hierarchy Setup flow leaves `FQS_Campaign_Category__c` blank on all Level 1 (Strategic) rollup campaigns. The field is only populated at Level 2 (Operational) and Level 3 (Tactical), where the semantic categorization (Major Gifts, Planned Giving, Events, Annual Giving, Grants, Corporate Match, In-Kind) actually applies to the underlying fundraising activity. If your team edits Level 1 campaigns manually, keep this field blank there as well — reserve `FQS_Campaign_Category__c` for Level 2/3 only. Reports and list-view filters that key off Category should exclude rollup rows via a hierarchy-depth filter (`FQS_Hierarchy_Depth__c IN (2, 3)`) or by excluding null Category.

## Backlog Items

<!-- TODO: replace the placeholder backlog with concrete items as they get scoped. Rough starting list: -->

* **Recurring Gift Retention Toolkit:** Additional dynamic-page components and reports focused on lapsing recurring donors and retention health.
* **Batch Gift Entry Templates:** Pre-built Gift Entry batch templates for common intake channels (event, direct mail, online, matching gift).
* **Payment Gateway Reconciliation:** Guidance and optional automation for reconciling Payment Instrument records with external gateway transactions.
* **Grant Lifecycle Handoffs:** Cleaner handoffs between Fundraising (Gift Commitment / Gift Transaction) and Grants Management for grant-funded revenue.
* **Localization and Translation:** Move hardcoded flow text to metadata labels to support future Spanish and French translation packs.
* **Automation Bypass Framework:** A supported switch for temporarily disabling FQS automation during bulk loads or data migrations.

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
