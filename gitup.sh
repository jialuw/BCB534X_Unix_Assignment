#quick way to push to github
#sh gitup.sh "commit"
git status
git add . 
git commit -m "$1"
git pull origin master
git push origin master
