# CHANGELOG

## 2024.9.22
- Bug fixes
- Improvements into data collection pipeline for daily backups

## 2024.9.10

- Multipart forms for API uploads implemented.
- VT Submission for verification
- UI bug fixes

## 2024.9.7

- Code to triage effected files.
- Introducing new **BREAKING** API changes, binaries will no longer be accepted as raw request body, multipart forms are being implemented .

## 2024.9.4

- Code to triage effected files.

## 2024.9.3

- Disabled VT submissions and API due to a bug in our input script.
- Making the API routes a little more bullet proof before opening them up again.

## 2024.9.2

1. VT API Rate Limiter:
   - A new module `Exchange.VtApiRateLimiter` has been implemented to manage rate limiting for VirusTotal API requests.
   - It uses a GenServer to maintain counters for different priority levels and enforces a total request limit.
   - The rate limiter is started in the application supervision tree with an initial limit configured in the runtime.exs file.

2. Oban Jobs:
   - Two new Oban job modules have been added: `Exchange.ObanJobs.Vt.StatusCheckVt` and `Exchange.ObanJobs.Vt.SubmitVt`.
   - These jobs handle the submission of samples to VirusTotal and checking the status of submitted samples.
   - They use the VT API Rate Limiter to respect rate limits when making API calls.

3. VirusTotal Service:
   - The module `Exchange.Services.VirusTotalPost` has been foled into `Exchange.Services.VirusTotal`
   - It provides functions for getting sample information, submitting files for processing, posting comments, and checking analysis status.

4. Samples Context:
   - The `Exchange.Samples` module has been updated to include functions for updating samples based on VirusTotal data and triggering VirusTotal submissions.

5. Configuration Changes:
   - New runtime configuration options have been added for virus total and rate limiting.
   - The Oban configuration has been updated to include new queues specifically for virus total requests.

6. Application Startup:
   - The `Exchange.Application` module now starts the VT API Rate Limiter as part of the application supervision tree.

These changes have several impacts on the application:

1. Improved VirusTotal Integration: The application can now submit samples to VirusTotal, retrieve analysis results, and update sample information based on VirusTotal data.

2. Rate Limiting: The VT API Rate Limiter ensures that the application respects VirusTotal's rate limits, preventing API abuse and potential service disruptions.

3. Background Processing: The use of Oban jobs allows for asynchronous processing of VirusTotal-related tasks, improving application responsiveness.

4. Configurability: The new configuration options allow for easier deployment and management of the application in different environments.

5. Scalability: The use of Oban and the rate limiter makes the application more scalable, as it can handle a large number of sample submissions and analysis requests without overwhelming the VirusTotal API.

## 2024.9.1

- Track User Uploads
