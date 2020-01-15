//
//  AboutSectionViewController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/17/14.
//
//

#import "AboutSectionViewController.h"

@interface AboutSectionViewController ()

@end

@implementation AboutSectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setModalPresentationStyle:UIModalPresentationFullScreen];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    abtView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAboutSectionFileName ofType:kAboutSectionFileExt] encoding:NSUTF8StringEncoding error:nil];
    abtView.text = [NSString stringWithFormat:abtView.text,[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]];
    abtView.font = [UIFont systemFontOfSize:kAboutSectionFontSize];
    abtView.textAlignment = NSTextAlignmentCenter;
    abtView.dataDetectorTypes = UIDataDetectorTypeLink;
    abtView.selectable = YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (![GlobalVars isIpad])
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
