terraform plan -out plan.json
rover -tfPath C:\hashicorp\terraform.exe -planPath plan.json
Expand-Archive .\rover.zip -DestinationPath .\rover\ -force

rover_v -planPath test.tfplan?
'docker run --rm -it -p 9000:9000 -v "C:/code/harrypotter:/src" im2nguyen/rover' 
