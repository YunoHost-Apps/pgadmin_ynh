
build_cmd_deb_1() {
    pushd ~
    sudo /root/build_pgadmin_bin.sh $1 $2 --chroot-yes
    popd
    sudo chown app_upgrader ~/$2*
}
build_cmd_deb_2() {
    local target_dir=~
    sudo chroot /mnt/bookworm_build /root/build_pgadmin_bin.sh $1 $2 --chroot-yes
    sudo mv -t $target_dir /mnt/bookworm_build/$2*
    sudo chown app_upgrader $target_dir/$2*
}


build_result_path_deb_1=~
build_result_path_deb_2=~

notify_email="hello@world.tld"

# For github arm release
owner="YunoHost-Apps"
repo="pgadmin_python_build"
perstok="kkk"
