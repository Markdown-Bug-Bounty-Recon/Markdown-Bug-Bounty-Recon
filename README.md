
# WORK IN PROGRESS

## The framework
### Finding Subdomain
- The script uses many tools to find subdomains and then it fetches it.
### Port Analysis
with tool ```masscan``` for discovering open ports
```nmap``` for service scanning
```brutespray``` for default credential bruteforcing
### Screnshotting
with tool ```Eyewitness```
### Subdomain takeover
with tool ```SubOver``` and ```nuclei```
## Other stuff
### Git Dorking
with tool ```GitDorker```
## TODO
- [ ] Implement parallelism with ```parallel```
- [ ] Convert output to JSON format and store it somewhere. It definetely would be more fail-proof thank having plaintext results redirected to markdown format.
