#!/usr/bin/perl -w

$DIR_NAME = "CM_14";
$fetch = "ssh://192.168.0.12:29418/";
$review = "http://192.168.0.12:8080/";

$curdir=`pwd`;
chomp $curdir;
$destdir = $curdir."/$DIR_NAME";
$list_path = $curdir."/project.list";
$project_info;

open (LFILE, $list_path) or die "Can't open project.list";
@list =<LFILE>;

foreach $git (@list)
{
	chomp $git;
	my $dir= $curdir."/".$git;
	chdir ($dir);
    $destgit = $destdir."/".$git.".git";
	if(-e ".git") {
		print "rm $dir/.git/\n";
		system("rm -rf .git/");
	}
	system("git init");
	system("git commit -m \"create bare git\" --allow-empty");
	system("git add .");
	system("git commit -a -m \"Source Base.\"");
 	system("git clone $dir --mirror  $destgit");
}

foreach $path(@list) {
	my $one_project_info;
	chomp $path;
	if($path eq "device/qcom/common") {
		$one_project_info = "  <project name=\"$DIR_NAME/$path\" path=\"$path\">\n";
		$one_project_info = $one_project_info."    <copyfile dest=\"build.sh\" src=\"build.sh\"/>\n";
		$one_project_info = $one_project_info."    <copyfile dest=\"vendor/qcom/build/tasks/generate_extra_images.mk\" src=\"generate_extra_images.mk\"/>\n";
		$one_project_info = $one_project_info."  </project>\n";
	}elsif($path eq "build") {
		$one_project_info = "  <project name=\"$DIR_NAME/$path\" path=\"$path\">\n";
		$one_project_info = $one_project_info."    <copyfile dest=\"Makefile\" src=\"core/root.mk\"/>\n";
		$one_project_info = $one_project_info."  </project>\n";
	}else {
		$one_project_info = "  <project name=\"$DIR_NAME/$path\" path=\"$path\"/>\n";
	}
	$project_info = $project_info.$one_project_info;
}

$destdir = $curdir."/$DIR_NAME"."/manifests";

system("mkdir $destdir");

open MFILE, ">$destdir/default.xml";
print MFILE  << "EOF";
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote fetch="$fetch" name="origin" review="$review"/>
  <default remote="origin" revision="master"/>

$project_info
</manifest>
EOF

chdir $destdir;
system("git init");
system("git add .");
system("git commit -a -m \"Create By perl\"");
system("git log");
chdir "../";
system("git clone manifests/.git --mirror manifests.git");
system("rm -rf manifests/");
chdir "../";
system("tar -zcvf $DIR_NAME.tgz $DIR_NAME");


