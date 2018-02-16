set userName to do shell script "w | awk 'FNR == 3 { print $1 }'"

try
	mount volume "smb://smb.isilonc02.bo1.csnzoo.com/legacy_u_drive/" & userName
end try