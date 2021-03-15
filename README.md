
# WORK IN PROGRESS

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

## On what topics and subject I'll focus for now?
- Definetely finding more root domains and subdomain enumeration, also discovering technologies and ways to use that data
- Also managing scope, detecting the scope of the program, put a massive distinction between passive scanning and active scanning to not make bug-bounty programs angry! D:
- Being the most accurate, **NOT FOLLOWING THE PHILOSOPHY "BRUTE SPRAY AND PRAY"**
- **I don't want to** focus on brute-forcing mainly, because in the end everyone does that, but someday I'll get down to it
## TODO
- [ ] Using Amass intel to get the company ASN number and more root domains
- [ ] Implement parallelism with ```parallel```
- [ ] Develop nuclei scanning more to take into account the output of get-technologies.sh
- [ ] Convert output to JSON format and store it somewhere with ```jq```. It definetely would be more fail-proof than having plaintext results redirected to markdown format.
- [ ] Record reports by date and check if there're any new findings worth to check out - can be done with implementing JSON format and then moving on with that further
- [ ] Make this script more colourful!
- [ ] Use bbrf for defining out-of-scope sudomains, domains
