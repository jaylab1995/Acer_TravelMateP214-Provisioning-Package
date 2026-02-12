@{
    # Configuration for the PSP Deployment Script

    # --- File Paths ---
    # Paths to the various data files used by the script.
    DataRoot = "..\Assets\Data"
    SoftwareRoot = "..\Assets\Software"

    # CSV Files
    UIConfig        = "UI_Config.csv"
    Password        = "pass.csv"
    MasterAccounts  = "ad_account.csv"
    LocalAdmin      = "master_local_account.csv"
    Technicians     = "cmt.csv"
    
    # --- Webhook & API ---
    # URIs for external services. (Leave blank if not used)
    DiscordWebhook = "https://discord.com/api/webhooks/1460909225193504863/gvNLOAYpGnc4GelBlx8LQY3WZLLnO339ya5fDHMTHihSkxwit-M2-zBVRzNEUpFWbQ30"
    GoogleSheetApi = ""
    
    # --- PC Naming Convention ---
    # The prefix to be used for the PC name. The MAC address will be appended.
    PCNamePrefix = "05-"
}
