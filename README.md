
# WORK IN PROGRESS / FOR PERSONAL USE / FOR INSPIRATION TO OTHERS <3

## How is this recon framework different from others?
- Puts every specific-subdomain data to particular folder associated with that subdomain, If you get comfortable with the directory structure then using this script will be a lot easier
- The concept of this script is to convert all findings into one Markdown report, then you can import this report to ```Notion```, share this file with others and then collaborate easier
- I want to make it run parallel
- No Cloud subscription required. I want these script to run locally in the background with 0$ 

## How to use this framework?
1. The easiest way is to use my docker container [blackarch-zsh](https://github.com/Cloufish/blackarch-zsh-container), create the ```~/Pentesting``` directory on the host machine and run the container
2. Then on the docker container change directory to this ```~/Pentesting``` directory and execute ```sudo full-web.sh -d ${domain} -u ${USER-EXEC}``` where ${domain} is your target domain and ${USER-EXEC} is the username home directory name **this is important, because otherwise finding would be put in /home/root/  which is not-intented``` (and I don't know how to remove the necessity of declaring this -u flag other than not executing as root)
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
- **This breaks a lot**, because with every new functionality I need to change this markdown-converter

## On which topics and subject I'll focus for now?
- Definetely finding more root domains and subdomain enumeration, also discovering technologies and ways to use that data
- Also managing scope, detecting the scope of the program, put a massive distinction between passive scanning and active scanning to not make bug-bounty programs angry! D:
- Being the most accurate, **NOT FOLLOWING THE PHILOSOPHY "BRUTE SPRAY AND PRAY"**
- **I don't want to** focus on brute-forcing mainly, because in the end everyone does that, but someday I'll get down to it
## TODO
- [ ] Create separate docker container for this script to run
- [x] Using Amass intel to get the company ASN number and more root domains
- [x] Implement parallelism with ```parallel```
- [ ] Develop nuclei scanning more to take into account the output of get-technologies.sh
- [ ] Convert output to JSON format and store it somewhere with ```jq```. It definetely would be more fail-proof than having plaintext results redirected to markdown format.
- [ ] Record reports by date and check if there're any new findings worth to check out - can be done with implementing JSON format and then moving on with that further
- [ ] Make this script more colourful!
- [ ] Use bbrf for defining out-of-scope sudomains, domains
- [ ] Notifications via Slack channel
