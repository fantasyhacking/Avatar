#!C:/Perl64/bin/perl

package Avatar;

use strict;
use warnings;

use Cwd;
use Method::Signatures;
use CGI qw(header -no_debug);
use GD;
use LWP::UserAgent;
use Scalar::Util qw(looks_like_number);
use List::Util qw(any);
use JSON qw(decode_json);
use Switch;

print "Content-type: image/png\n\n";	

method new($resAPI) {
	   my $obj = bless {}, $self;
	   my $paper_json = 'http://cdn.clubpenguin.com/play/en/web_service/game_configs/paper_items.json';
	   $obj->{api} = $resAPI;
	   $obj->{ext} = '.png';
	   $obj->loadItems($paper_json);
	   return $obj;
}

method loadItems($paper_json) {
	   my $resContent = decode_json(LWP::UserAgent->new->get($paper_json)->decoded_content);
	   for my $item (values @{$resContent}) {
		   my $intType = $item->{type};
		   my $intItem = $item->{paper_item_id};
		   my $strType = '';
		   switch ($intType) {
					case (1) { $strType = 'COLOR'; }
					case (2) { $strType = 'HEAD'; }
					case (3) { $strType = 'FACE'; }
					case (4) { $strType = 'NECK'; }
					case (5) { $strType = 'BODY'; }
					case (6) { $strType ='HAND'; }
					case (7) { $strType = 'FEET'; }
					case (8) { $strType = 'FLAG'; }
					case (9) { $strType = 'PHOTO'; }
					case (10) { $strType = 'OTHER'; }
					else { $strType = 'OTHER'; }
			}
		   %{$self->{items}->{$intItem}} = (type => $strType);
	   }
}

method isValidSize($intSize) {
		my @arrSizes = (60, 88, 120, 300, 600);
		if (any {$_ == $intSize} @arrSizes) {
			return 1;
		} else { 
			return 0;
		}
}

method constructAvatar($strItems, $intSize = 300) {
	GD::Image->trueColor(1);
	if ($self->isValidSize($intSize)) {
			my @arrItems = split('-', $strItems);
			my $intColor = $arrItems[0];
			if (looks_like_number($intColor) && $intColor <= 16) {
				my $avatarPenguin = $self->{api} . $intSize . '/' . $intColor . $self->{ext};
				my $resAvatarPenguin = LWP::UserAgent->new->request(new HTTP::Request GET => $avatarPenguin)->content;
				my $penguinImage = GD::Image->new($resAvatarPenguin); 		
				foreach my $intItem (values @arrItems) {   
					if (looks_like_number($intItem) && exists($self->{items}->{$intItem}) && $self->{items}->{$intItem}->{type} eq 'PHOTO') {
						my $avatarPhoto = $self->{api} . $intSize . '/' . $intItem . $self->{ext};
						my $resAvatarPhoto = LWP::UserAgent->new->request(new HTTP::Request GET => $avatarPhoto)->content;
						my $photoImage = GD::Image->new($resAvatarPhoto); 
						$photoImage->copy($penguinImage, 0, 0, 0, 0, $intSize, $intSize);
						$penguinImage = $photoImage;
					}
				} 			
				foreach my $intItem (values @arrItems) {    
					if (looks_like_number($intItem) && $intItem != $intColor && exists($self->{items}->{$intItem}) && $self->{items}->{$intItem}->{type} ne 'PHOTO') {
						my $avatarItems = $self->{api} . $intSize . '/' . $intItem . $self->{ext};
						my $resAvatarItems = LWP::UserAgent->new->request(new HTTP::Request GET => $avatarItems)->content;
						my $itemImage = GD::Image->new($resAvatarItems);
						$penguinImage->copy($itemImage, 0, 0, 0, 0, $intSize, $intSize);
					}
				}	 			
				$penguinImage->alphaBlending(0);
				$penguinImage->saveAlpha(1);
				print $penguinImage->png; 
			}
		}    
}

1;
