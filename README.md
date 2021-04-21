
# WORK IN PROGRESS / FOR PERSONAL USE / FOR INSPIRATION TO OTHERS <3

## How is this recon framework different from others?
- Puts every specific-subdomain data to particular folder associated with that subdomain, If you get comfortable with the directory structure then using this script will be a lot easier
- The concept of this script is to convert all findings into one Markdown report, then you can import this report to ```Notion```, share this file with others and then collaborate easier
- I want to make it run parallel
- No Cloud subscription required. I want these script to run locally in the background with 0$

## How to use this framework?
1. The easiest way is to use my docker container [bug-bounty-framework](https://github.com/Cloufish/blackarch-zsh-container/tree/master/bug-bounty-framework-web), create the ```~/Pentesting``` directory on the host machine and run the container
2. Then on the docker container change directory to this ```~/Pentesting``` directory and execute ```sudo full-web.sh -d ${domain} -u ${USER-EXEC}``` where ${domain} is your target domain and ${USER-EXEC} is the username home directory name **this is important, because otherwise finding would be put in /home/root/  which is not-intented**  (and I don't know how to remove the necessity of declaring this -u flag other than not executing as root)
## For now though I'll present to you what each script does:

### full_web.sh
- Performs full scan, when you look at it you'll see exactly what the framework does and what in which steps it executes other scripts
### get-technologies.sh
- Gets the technologies which the site uses, for now it's only using ```wappalyzer cli```, but there'll be more!
### get-subdomains-passively.sh
- This performs all the subdomain enumeration passively, without active scanning with ```amass```
### get-alive-subdomains.sh
- This script checks, if the addresses from ```get-subdomains-passively.sh``` are resolvable, and also performs subdomain brute-forcing - also with ```amass```
### get-not-alive-subdomains-ip.sh
- This script resolves every not_active subdomain to it's ip public ip address
### bruting-not-alive-subdomains-ip.sh
- This will perform brute-forcing on services that the not-alive subdomains run
- **Still in progress**
### extracting-javascript.sh
- This will extract javascript from the website, and also search for other sources
- **Still in progress**
### bruting-alive-subdomains.sh
- This will brute and test alive subdomains with nuclei
- **Still in progress**
### markdown_converter.sh
- This converts the contents of tools-io directory to markdown
- **This breaks a lot**, because with every new functionality I need to change this markdown-converter, so It doesn't cover much of the brute-forcing part.
- The main concept is that It keeps all the findings dynamically updating (new subdomains etc.), but the ```notes.mdpp``` is static and only you will be filling its content!
## On which topics and subject I'll focus for now?
- Definetely finding more root domains and subdomain enumeration, also discovering technologies and ways to use that data
- Also managing scope, detecting the scope of the program, put a massive distinction between passive scanning and active scanning to not make bug-bounty programs angry! D:
- Being the most accurate, **NOT FOLLOWING THE PHILOSOPHY "BRUTE SPRAY AND PRAY"**
- **I don't want to** focus on brute-forcing mainly, because in the end everyone does that, but someday I'll get down to it
## TODO
- [ ] Create separate docker container for this script to run and make it with set ```cron```
- [x] Using Amass intel to get the company ASN number and more root domains
- [x] Implement parallelism with ```parallel```
- [ ] Include get-technologies.sh output in markdown
- [ ] Implement uploading to imgur via their API
- [ ] Integrate nuclei scanning
- [ ] Record reports by date and check if there're any new findings worth to check out - Can be done with executing ```sdiff``` on each file in ```tools-io/``` but also with comparing markdown report
- [ ] Make directory for Notes separate - after all the files in there would be filled the most frequent
- [ ] Also make the possibility to include ignore.txt file to ignore these new findings ( If We want to prevent them from appearing )
- [ ] Make separate shodan script with API key
- [ ] Make basic documentation with ```docsify```
- [x] Make this script more colourful!
- [ ] Jeez, just get ``` extracting-javascript.sh``` working!!!
- [ ] Redirect unneceseary output to /dev/null in favor of ```-o``` flag whenever possible
- [ ] Define out of scope addresses with the help of regex expressions (and grex to generate them)
- [ ] Make it so the any setting performed in docker container with ```docker attach``` is persistent when doing a reboot, or store and copy the configs between Host and Container
- [ ] Also have a way to manage ```$SECRET_TOKENS``` in a secure and simple manner, probably with [env-files] (https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file) while on the Host machine have a bash script/docs on how to assign them
- [ ] Notifications via Slack channel
- [ ] Separate things put in recon and things put on Slack - The markdown report should be source of information - not the source for 'Incident Response'(? xD) when nuclei or ZAP finds anything
- [ ] Implement ZAP with their Automation Framework
- [ ] Backups of the data (Mainly reports)
- [ ] Use EyeWitness
- [ ] After some long time, let's replace markdown with ```rmarkdown```, add sweet charts, visualizations :)
