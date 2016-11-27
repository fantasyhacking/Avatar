#!C:/Perl64/bin/perl

package Avatar;

use strict;
use warnings;

use Cwd;
use Method::Signatures;
use CGI qw(header -no_debug);
use GD;
use File::Fetch;
use Scalar::Util qw(looks_like_number);

print "Content-type: image/png\n\n";	

method new($resAPI) {
	   my $obj = bless {}, $self;
	   $obj->{api} = $resAPI;
	   $obj->{ext} = '.png';
	   return $obj;
}

method constructAvatar($strItems, $intSize = 300) { #implement directory creating, types and avatar sizes
	    GD::Image->trueColor(1);
        my @arrItems = split('-', $strItems);
        my $intColor = $arrItems[0];
        my $newImage = GD::Image->new($intSize, $intSize);
        my $avatarPenguin = $self->{api} . $intSize . '/' . $intColor . $self->{ext};
        File::Fetch->new(uri => $avatarPenguin)->fetch(to => (cwd() . '/Clothing/Penguin'));
        my $penguinImage = GD::Image->new((cwd() . '/Clothing/Penguin/' . $intColor . $self->{ext}));  
        foreach my $intItem (values @arrItems) {    
            if ($intItem != $intColor) {
                my $avatarItems = $self->{api} . $intSize . '/' . $intItem . $self->{ext};
                File::Fetch->new(uri => $avatarItems)->fetch(to => (cwd() . '/Clothing/Items'));
                my $itemImage = GD::Image->new((cwd() . '/Clothing/Items/' . $intItem . $self->{ext}));
                $penguinImage->copy($itemImage, 0, 0, 0, 0, $intSize, $intSize);
            }
        }
        $penguinImage->alphaBlending(0);
        $penguinImage->saveAlpha(1);
        print $penguinImage->png;     
}

1;
