//
//  FilePickerController.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 1/4/13.
//
//

#import "FilePickerController.h"

@interface FilePickerController ()

@end

@implementation FilePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma Set up methods

- (void)viewDidLoad
{
    parametersController = [[ParametersController alloc] init];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpDefaultFiles {
    defaultRefFilesNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultRefFilesNamesFile ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
    
    defaultReadsFilesNames = [[NSMutableArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultReadsFilesNamesFile ofType:kTxt] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
}

#pragma Button Actions

- (IBAction)showParametersPressed:(id)sender {
    NSString *s = [defaultRefFilesNames objectAtIndex:[referenceFilePicker selectedRowInComponent:0]];//Component 0 for default files for now
    
    NSString *r = [defaultReadsFilesNames objectAtIndex:[readsFilePicker selectedRowInComponent:0]];
    
    [parametersController passInSeq:s andReads:r];
    [self presentModalViewController:parametersController animated:YES];
}

- (IBAction)backPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma Picker View Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return kNumOfComponentsInPickers;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:referenceFilePicker])
        return [defaultRefFilesNames count];
    else
        return [defaultReadsFilesNames count];
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView isEqual:referenceFilePicker])
        return [defaultRefFilesNames objectAtIndex:row];
    else
        return [defaultReadsFilesNames objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
