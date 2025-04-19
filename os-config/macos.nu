# Update brew packages and check for issues
def brewup [] {
    ^brew update
    do -i { ^brew upgrade; ^brew cleanup }
    ^brew doctor
}
