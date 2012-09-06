//
//  NoticiaViewController.m
//  ElDia2
//
//  Created by Lion User on 27/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import "NoticiaViewController.h"
#import "AppDelegate.h"
#import "EGOPhotoGlobal.h"


@implementation NoticiaViewController

@synthesize mainUIWebView,bottomUIView, optionsBottomMenuUIImageView;

- (IBAction) btnBackClick: (id)param{
  [[app_delegate navigationController] popViewControllerAnimated:YES];
}
- (IBAction) btnShareClick: (id)param{
  NSString *dirPath = [[NSBundle mainBundle] bundlePath];
 	NSURL *dirURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
  
  [self.mainUIWebView loadHTMLString:@"<html xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:news=\"http://www.diariosmoviles.com.ar/news-rss/\">   <head>   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">   <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width\">   <link rel=\"stylesheet\" type=\"text/css\" media=\"only screen and (max-device-width: 480px)\" href=\"2.css\">   <title>XXX</title>   </head>   <body bgcolor=\"#ffffff\"><section class=\"entry_open\"><div>   <section class=\"header\"><h2></h2>   <h1>Sabella convoc&amp;#243; a Ustari</h1>   <p class=\"subheader\">El arquero suplente de Boca fue llamado para integrar la Selección y esta tarde se sumará a los entrenamientos en Ezeiza, con miras a los partidos contra Paraguay y Perú</p>   <span class=\"entry_meta\">Mon, 3 Sep 2012 12:43:37 -0300</span></section><div class=\"separator\"></div>   <section class=\"cuerpo\">El arquero de Boca Juniors, Oscar Ustari, fue convocado al seleccionado argentino por el entrenador Alejandro Sabella y esta tarde se sumará a los entrenamientos con vistas a los partidos ante Paraguay y Perú por las Eliminatorias para el Mundial de Brasil 2014.   El seleccionado argentino entrenará desde las 17, en el predio de AFA en Ezeiza, y Ustari se sumará a Maximiliano Rodríguez, Clemente Rodríguez, Rodrigo Braña (convocados del medio local), Marcos Rojo, Ezequiel Lavezzi, Hernán Barcos, Pablo Zabaleta y Pablo Guiñazú (llegados del exterior).   Los futbolistas que juegan en la Argentina no podrán integrar sus equipos en la próxima fecha del torneo Inicial de primera división, a jugarse entre el sábado y el lunes.   Mañana se sumarán a los entrenamientos Lionel Messi, Fabricio Coloccini, Angel Di María, Gonzalo Higuaín, Sergio Romero, Enzo Pérez, Ezequiel Garay, Fernando Gago, Mariano Andújar, Rodrigo Palacio, Hugo Campagnaro, Federico Fernández, José Sosa y Lucas Biglia.   Sergio Agüero también asistirá a la práctica de esta tarde pero para ser evaluado por el cuerpo médico del equipo nacional, ya que se recupera de un traumatismo en la rodilla derecha, el 19 de agosto en un partido contra el Southampton por la Premier League .   El delantero del Manchester City está descartado para el partido del próximo viernes con Paraguay, en Córdoba, y es duda para el del martes, en Lima, ante Perú</section>   </div></section></body>   </html>" baseURL:dirURL];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.mainUIWebView.delegate = self;
  self.mainUIWebView.hidden = NO;
  // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
  app_delegate.navigationController.navigationBar.hidden=YES;
}
  
- (void)webView:(UIWebView*)sender zoomingEndedWithTouches:(NSSet*)touches event:(UIEvent*)event
{
	NSLog(@"finished zooming");
}

- (void)webView:(UIWebView*)sender tappedWithTouch:(UITouch*)touch event:(UIEvent*)event
{
	NSLog(@"tapped");
  [self singleTapWebView];
}

- (void)singleTapWebView {
  self.bottomUIView.hidden = !self.bottomUIView.hidden;
  //NSLog(@"singleTapWebView");
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
  NSLog(@"webViewDidFinishLoad");
}

 -(void)webViewDidStartLoad:(UIWebView *)webView{
  NSLog(@"webViewDidStartLoad");
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
  NSLog(@"didFailLoadWithError: %@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType{
  
  NSURL* url = [request URL];
  
  //validar URL
  if (UIWebViewNavigationTypeLinkClicked == navigationType)
  {
    [self loadPhotoGallery:url];
    return NO;
    //NSURL* url = [request URL];
  }
  //NSLog(@"NoticiaViewcontroller:shouldStartLoadWithRequest:navigationType %u", navigationType);
  return YES;
}

-(void) loadPhotoGallery:(NSURL *)url{
  
  NSLog(@" NSURL - 1: %@", [url absoluteString]);
  /*
  NSLog(@" NSURL - 2: %@", [url baseURL]);
  NSLog(@" NSURL - 3: %@", [url query]);
  NSLog(@" NSURL - 4: %@", [url path]);
  NSLog(@" NSURL - 5: %@", [url pathComponents]);
  */
  NSString *_gallery_proto = @"gallery://";
  NSString *_url=[url absoluteString];
  
  NSRange range = [_url rangeOfString:_gallery_proto];
  
  if ( range.length <= 0 ) {
    NSLog(@"loadPhotoGallery: [range.length <= 0] HAS NO PHOTO!");
    return;
  }
  
  _url=[_url stringByReplacingOccurrencesOfString:_gallery_proto withString:@""];
  NSArray *_images_src = [_url componentsSeparatedByString:@";"];
  
  if([_url length]<=0){
    NSLog(@"loadPhotoGallery: [[_url length]<=0] HAS NO PHOTO!");
    return;
  }
  
  if([_images_src count]<1){
    NSLog(@"loadPhotoGallery: [[_images_src count]<1] HAS NO PHOTO!");
    return;
  }
  
  /*
   http//media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f1.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f2.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f3.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f4.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f5.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f6.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f7.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f8.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f9.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f10.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f11.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f12.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f13.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f14.jpg
   http://media.eldia.com.ar/%2fediciones%2f20120902%2fsola%2f15.jpg
   */
  
  /*MyPhoto *photo = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:@"http://a3.twimg.com/profile_images/66601193/cactus.jpg"] name:@" laksd;lkas;dlkaslkd ;a"];
  MyPhoto *photo2 = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:@"https://s3.amazonaws.com/twitter_production/profile_images/425948730/DF-Star-Logo.png"] name:@"lskdjf lksjdhfk jsdfh ksjdhf sjdhf ksjdhf ksdjfh ksdjh skdjfh skdfjh "];
  MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:[NSArray arrayWithObjects:photo, photo2, photo, photo2, photo, photo2, photo, photo2, nil]];
  
  EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
  
  navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  navController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentModalViewController:navController animated:YES];
  
  [navController release];
  [photoController release];
  [photo release];
  [photo2 release];
  [source release];*/
  
  NSMutableArray *_array = [[NSMutableArray alloc] initWithCapacity:[_images_src count]];
  for (int *i = 0; i < [_images_src count]; i++) {
    EGOQuickPhoto *photo = [[EGOQuickPhoto alloc] initWithImageURL:[NSURL URLWithString:[_images_src objectAtIndex:i]] name:@""];
    [_array addObject:photo];
    
  }
  
  /*EGOQuickPhoto *photo = [[EGOQuickPhoto alloc] initWithImageURL:[NSURL URLWithString:@"http://a3.twimg.com/profile_images/66601193/cactus.jpg"] name:@" laksd;lkas;dlkaslkd ;a"];
  EGOQuickPhoto *photo2 = [[EGOQuickPhoto alloc] initWithImageURL:[NSURL URLWithString:@"https://s3.amazonaws.com/twitter_production/profile_images/425948730/DF-Star-Logo.png"] name:@"lskdjf lksjdhfk jsdfh ksjdhf sjdhf ksjdhf ksdjfh ksdjh skdjfh skdfjh "];
  EGOQuickPhotoSource *source = [[EGOQuickPhotoSource alloc] initWithPhotos:[NSArray arrayWithObjects:photo, photo2, photo, photo2, photo, photo2, photo, photo2, nil]];
  */
  EGOQuickPhotoSource *source = [[EGOQuickPhotoSource alloc] initWithPhotos:_array];
  EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
  
  [app_delegate.navigationController  pushViewController:photoController animated:YES];
  app_delegate.navigationController.navigationBar.hidden=NO;
  /*[photoController release];
  [photo release];
  [photo2 release];
  [source release];*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
