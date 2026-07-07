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
* A `FQS_Donor_Grouping__mdt` custom metadata type for classifying donors into named tiers (major, mid-level, sustaining, first-time, lapsed) without hard-coding thresholds in flows or reports.
* A `FQS_Custom_Fields` permission set to assist admins in providing access to the accelerator's custom fields and functionality.

### Included Assets

An unmanaged package (link in the installation section of this document; metadata is also found in the [/force-app/main/default/](/force-app/main/default/) folder) that includes:

* A Lightning app: **Fundraising Quick Start**
* Dynamic Lightning record pages for: Campaign, Gift Transaction, Gift Commitment, Gift Commitment Schedule, Gift Designation, Gift Default Designation, Gift Transaction Designation, Gift Soft Credit, Gift Default Soft Credit, Gift Tribute, Gift Refund, Gift Commitment Change Attribute Log, Donor Gift Summary, Outreach Source Code, Outreach Summary, Payment Instrument, and Opportunity
* Custom fields, help text, and description updates on standard Fundraising objects (Gift Transaction, Gift Commitment, Gift Designation, and related)
* A custom Campaign record type (`FQS_Fundraising`) for fundraising campaigns
* A custom metadata type (`FQS_Donor_Grouping__mdt`) for donor tier definitions
* Custom quick actions and path assistants for gift-entry workflows
* A permission set: **FQS Custom Fields**

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

1. **Assign the Default Workflow User**

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

2. **Enable Nonprofit Cloud Fundraising**
   1. In Setup, search for **Fundraising**, and select **Fundraising Settings**.
   2. Turn on **Fundraising Tools for Everyone**.
   3. <!-- TODO: any additional Fundraising Settings toggles required (recurring gifts, tributes, matching, refunds) -->

3. **Assign the Fundraising_Admin Permission Set Group**
   1. From Setup, in the Quick Find box, enter **Permission Set Groups**, and then select **Permission Set Groups**.
   2. Click **Recently Viewed** and then select **All Permission Set Groups**.
   3. Click the permission set group name **Fundraising_Admin** in the list view.
   4. Click **Manage Assignments** and then **Add Assignments**.
   5. Select each user to whom you want to assign the group, and then click **Next**.
   6. Optionally, select an expiration date for the user assignment to expire.
   7. Click **Assign**.

4. **Enable Person Accounts for Fundraising** (only if not already enabled via Stakeholder Management Quick Start)
   1. <!-- TODO: reference SMQS steps or link to sfdo.fundraising_enable_person_accounts_for_fundraising.htm -->

5. **Enable Multiple Address Management** (only if not already enabled via Stakeholder Management Quick Start)
   1. <!-- TODO: cross-reference SMQS or provide standalone steps -->

6. **Enable Data Protection and Privacy** (only if not already enabled via Stakeholder Management Quick Start)
   1. <!-- TODO: cross-reference SMQS or provide standalone steps -->

7. <!-- TODO: any additional pre-install setting (payment gateway config, currency setup) that FQS depends on -->

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

2. **[Next Setting Name]**
   1. From Setup, in the Quick Find box, enter '[Setting]', and then select **[Setting]**.
   2. [Steps]

**II. Assign Permission Sets**

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

<!-- TODO: add additional permission sets as they are built out
2. **Assign the FQS Gift Entry Permission Set**
3. **Assign the FQS Gift Refunds Permission Set**
4. **Assign the FQS Donor Summary Permission Set**
-->

**III. Configure Gift Transaction and Gift Commitment Access**

<!-- TODO: fill out with the concrete profile / permission-set / page-layout / record-type assignments that need to happen. Rough shape:
1. Provide access to the FQS Fundraising Campaign Record Type
2. Modify Gift Transaction Page Layouts (assign SMQS-equivalent FQS layouts)
3. Modify Gift Commitment Page Layouts
4. Modify Search Layouts on Gift Transaction and Gift Commitment
5. Modify List View Button Layouts on Gift Transaction and Gift Commitment
-->

**IV. Configure Designation, Soft Credit, and Tribute Objects**

<!-- TODO: fill out per-object configuration steps. Candidates:
1. Modify the Gift Designation Object (picklist cleanup on FQS_Restriction_Type__c, IsActive default, help text)
2. Modify the Gift Default Designation Object
3. Modify the Gift Transaction Designation Object
4. Modify the Gift Soft Credit Object
5. Modify the Gift Default Soft Credit Object
6. Modify the Gift Tribute Object
-->

**V. Configure Refunds, Payment Instruments, and Outreach**

<!-- TODO: fill out with the steps to enable Gift Refunds and wire up Outreach Source Code / Outreach Summary. Candidates:
1. Modify the Gift Refund Object (lookup filters, help text, page layout)
2. Modify the Payment Instrument Object (record types, page layout)
3. Modify Outreach Source Code and Outreach Summary picklists
-->

**VI. Configure App Access**

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

**Reconcile with Your Chart of Accounts:** The `FQS_Restriction_Type__c` field on Gift Designation and the `FQS_Donor_Grouping__mdt` custom metadata type are intentionally admin-editable. Confirm their values match the categories your finance team already uses for external reporting (990, audited financials, board dashboards) rather than inventing new ones.

**Adjust Duplicate Rules:** Review and update your standard Salesforce Duplicate and Matching Rules to support the record types and field usage patterns introduced by this accelerator (particularly Campaigns of type `FQS_Fundraising`).

**Build an Automation Bypass:** <!-- TODO: describe the recommended bypass pattern once flows are finalized. Candidate: add a Bypass_Automation__c checkbox to flow entry criteria to short-circuit sync flows during bulk data loads. -->

**Salesforce Documentation:**

* **Validation Rules Guide:** [Validation Rules Documentation](https://help.salesforce.com/s/articleView?id=platform.fields_about_field_validation.htm&language=en_US&type=5)
* **Duplicate Rules Guide:** [Duplicate Rules Map of Reference](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_map_of_reference.htm&type=5)
* **Duplicate Rules Framework:** [Things to Know About Duplicate Rules](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_overview.htm&type=5)
* **Standard OOTB Rules:** [Standard Duplicate Rules Reference](https://help.salesforce.com/s/articleView?id=sales.duplicate_rules_standard_rules.htm&type=5)

### 6. Reporting and Dashboards

<!-- TODO: describe recommended reports / dashboards that pair with this accelerator, or point at the Fundraising analytics app. Candidates:
* Recurring Gift retention
* Donor tier movement (using FQS_Donor_Grouping__mdt)
* Restriction-type breakdown of committed revenue
* Refund and adjustment audit
* Outreach attribution (source code -> gift)
-->

### 7. Currency, Fiscal Year, and Multi-Entity Considerations

<!-- TODO: describe how this accelerator behaves under multi-currency, custom fiscal years, and multi-entity setups. Note anything that is out of scope. -->

## Known Issues

* None <!-- TODO: capture known issues as they surface during beta / partner testing -->

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
