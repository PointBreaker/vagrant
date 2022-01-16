node default {

    Exec {
        path => [
            '/usr/local/sbin',
            '/usr/local/bin',
            '/usr/sbin',
            '/usr/bin',
            '/sbin',
            '/bin'
        ]
    }

    $home = "/home/vagrant"

    # Configure apt

    class { "apt":
        update => {
            frequency => 'daily',
        },
    }

    include apt::update

    Exec['apt_update'] -> Package <| |>

    # Install some required packages

    package {[
            "ack-grep",
            "binutils",
            "cgdb",
            "clang",
            "clang-format",
            "cmake",
            "exuberant-ctags",
            "g++",
            "gcc",
            "gdb",
            "git",
            "libxrandr-dev",
            "libncurses5",
            "libncurses5-dev",
            "qemu",
            "silversearcher-ag",
            "tmux",
            "vim",
            "valgrind",
            "autoconf",
            "wget",
            "python3",
            "libjson-c-dev",
            "libfuse-dev",
            "sudo",
            "glibc-doc",
            "libx32gcc-4.8-dev",
            "libc6-dev-i386",
        ]:
          ensure => installed;
    }

    # Clone the skeleton files

    Vcsrepo {
        provider => git,
        require  => Package[git],
        user     => vagrant,
        group    => vagrant,
    }

    file {
        "$home/code/":
            ensure => directory,
            owner  => vagrant,
            group  => vagrant;
    }
    ->
    vcsrepo {
        "$home/code/group":
            ensure => present,
            source => "https://github.com/Berkeley-CS162/group0.git",
            remote => staff;
        "$home/code/personal":
            ensure => present,
            source => "https://github.com/Berkeley-CS162/student0.git",
            remote => staff;
        "$home/.fzf":
            ensure => present,
            source => "https://github.com/junegunn/fzf.git",
            remote => "origin",
            revision => "0.25.0";
    }
    ->
    # Set up some project support stuff
    class { ["cs162::bochs", "cs162::golang", "cs162::shell"]:
        home_directory => $home,
        owner          => vagrant,
        group          => vagrant,
    }
    ->
    class { ["cs162::fzf_install"]:
        home_directory => $home,
        owner          => vagrant,
        group          => vagrant,
    }


    include cs162::samba

    file {
        "/usr/bin/qemu":
            ensure => "/usr/bin/qemu-system-x86_64";
    }

}
