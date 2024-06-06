1. install and az devops cli and github cli on powershell
2. create label on github.
  - go to your repository->issues->label->create label.
  - name the label 'task'.
  - add any other label you need such as "user story", "bug", "feature"
3. get the azure devops PAT (with permission to read work items) for that repo. COPY AND SAVE.
4. get github token. COPY AND SAVE.
5. now we need to create github app
  - MAKE SURE TO SAVE THE APP ID, INSTALLATION ID AND PRIVATE KEY; follow the steps in the following link
  - https://josh-ops.com/posts/github-apps/#creating-a-github-app
  - during the process make the permissions:
      - repository: contents = read, issues = read and write
      - organization: members = read
  - create private key. SAVE AND COPY PRIVATE KEY. this can be done by opening the private key file in vscode and selecting copy the key text.
6. go to the github repository->settings(press 3 dots on upper right)->secrets and variables-> actions->new repository secret
  - first secret name is ADO_PAT. value is the azure devops PAT from step 3
  - second secret name is PRIVATE_KEY. the value is from step 5.
7. now with all the information needed, edit the migrate-work-items.yml and save at the end
  - line 9: Azure DevOps organization name to migrate from
  - line 13: Azure DevOps project name to migrate from
  - line 17: Azure DevOps area path to migrate from
    - can find this if you go to one of the work items and copy the name at area
  - line 31: GitHub organization name to migrate work items to
    - in my case i didnt have organization, i just put my github username and it worked
  - line 35: GitHub repo name to migrate work items to
  - line 61: change the app_id to the App ID you got from step 5
  - line 62: update the installation id that you got from step 5
8. now run in the terminal with the following command:
  - ./ado_workitems_to_github_issues.ps1 -ado_pat <AZURE PAT HERE> -ado_org <DEVOPS ORGANIZATION NAME> -ado_project <AZURE PROJECT NAME> -ado_area_path <AZURE AREA PATH> -gh_pat <GITHUB PAT> -gh_org <ORGANIZATION NAME/USERNAME> -gh_repo <GITHUB REPO NAME>
