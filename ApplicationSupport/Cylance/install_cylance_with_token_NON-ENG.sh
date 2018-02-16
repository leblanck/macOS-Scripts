#!/bin/sh
#!/bin/bash

echo cAAbCcd4e525I0AMpygYIXV8 > /private/tmp/Cylance/cyagent_install_token
echo VenueZone="04. macOS PROTECT" >> /private/tmp/Cylance/cyagent_install_token
sudo installer -pkg /private/tmp/Cylance/CylancePROTECT.pkg -target /

exit 0
