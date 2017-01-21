//
//  MainTableViewController.m
//  Application
//
//  Created by Vladyslav Kudelia on 12.09.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "MainTableViewController.h"
#import "CustomTableViewCell.h"
#import "CarObject.h"
#import "JSONDocument.h"
#import "CarLibrary.h"
#import "SQLiteManager.h"
#import "EditTableViewController.h"

@interface MainTableViewController () <UISearchResultsUpdating>

@property (strong, nonatomic) NSMutableArray *carRow;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *filteredCars;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table"]];
    
    [self loadDataFrom];
    [self createSearchController];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    contentOffset.y += _searchController.searchBar.frame.size.height;
    self.tableView.contentOffset = contentOffset;
    
    [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.tableView reloadData];
    } completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSSortDescriptor *sortDiscriptor = [[NSSortDescriptor alloc] initWithKey:@"mark" ascending:true];
    [_carRow sortUsingDescriptors:[NSArray arrayWithObject:sortDiscriptor]];
    
    [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.tableView reloadData];
        NSLog(@"update");
    } completion:nil];
}


- (IBAction)addNewDataAction:(UIBarButtonItem *)sender {
    CarObject *newCar = [CarObject new];
    newCar.mark = @"Unknown";
    newCar.model = @"Unknown";
    newCar.year = 1000;
    newCar.image = [UIImage imageNamed:@"nill"];
    
    [_carRow addObject:newCar];
    
    [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.tableView reloadData];
    } completion:nil];
}

- (IBAction)saveDataToAction:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save data to..." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *jsonMain = [UIAlertAction actionWithTitle:@"JSON" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            JSONDocument *document = [JSONDocument sharedLibrary];
            
            [document saveJSONFrom:_carRow];
            
            [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.tableView reloadData];
            } completion:nil];
        });
    }];
    
    UIAlertAction *sqliteMain = [UIAlertAction actionWithTitle:@"SQLITE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CarLibrary *library = [CarLibrary sharedLibrary];
            [library deleteSQLiteAllData];
            [library saveDataFromArray:_carRow];
            [_carRow removeAllObjects];
            [library initializeLibrary];
            
            [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.tableView reloadData];
            } completion:nil];
        });
    }];
    
    [alert addAction:jsonMain];
    [alert addAction:sqliteMain];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (IBAction)backToMainMenuAction:(UIBarButtonItem *)sender {
    [_carRow removeAllObjects];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainView"];
    [self presentViewController:viewController animated:true completion:nil];
}

- (void)createSearchController {
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];;
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = false;
    self.definesPresentationContext = true;
    
    _filteredCars = [NSMutableArray new];
    
    self.tableView.tableHeaderView = _searchController.searchBar;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = _searchController.searchBar.text;
    
    [_filteredCars removeAllObjects];
    
    for (CarObject *car in _carRow) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.mark contains[c] %@", searchString];
        [_filteredCars addObjectsFromArray:[@[car] filteredArrayUsingPredicate:predicate]];
    }
    
    [self.tableView reloadData];
}

- (void)loadDataFrom {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Load data from..." message:@"Notice: Default JSON - readonly" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *jsonDefault = [UIAlertAction actionWithTitle:@"Default JSON" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            JSONDocument *document = [JSONDocument sharedLibrary];
            _carRow = [NSMutableArray new];
            
            [document loadJSONFromDefaultData];
            
            _carRow = document.cars;
            
            NSSortDescriptor *sortDiscriptor = [[NSSortDescriptor alloc] initWithKey:@"mark" ascending:true];
            [_carRow sortUsingDescriptors:[NSArray arrayWithObject:sortDiscriptor]];
            
            [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.tableView reloadData];
            } completion:nil];
        });
    }];
    
    UIAlertAction *jsonMain = [UIAlertAction actionWithTitle:@"JSON DB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            JSONDocument *document = [JSONDocument sharedLibrary];
            _carRow = [NSMutableArray new];
            
            [document loadJSONFromNewData];
            
            if (document.cars.count == 0) {
                [document loadJSONFromDefaultData];
                [document saveJSONFrom:_carRow];
            }
            
            _carRow = document.cars;
            
            NSSortDescriptor *sortDiscriptor = [[NSSortDescriptor alloc] initWithKey:@"mark" ascending:true];
            [_carRow sortUsingDescriptors:[NSArray arrayWithObject:sortDiscriptor]];
            
            [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.tableView reloadData];
            } completion:nil];
        });
    }];
    
    UIAlertAction *sqliteMain = [UIAlertAction actionWithTitle:@"SQLite DB" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CarLibrary *library = [CarLibrary sharedLibrary];
            
            [library initializeLibrary];
            
            if (library.cars.count == 0) {
                NSLog(@"new sql");
                [library buildLibraryFromJSON];
                [library initializeLibrary];
            }
            
            _carRow = [NSMutableArray new];
            _carRow = library.cars;
            
            NSSortDescriptor *sortDiscriptor = [[NSSortDescriptor alloc] initWithKey:@"mark" ascending:true];
            [_carRow sortUsingDescriptors:[NSArray arrayWithObject:sortDiscriptor]];
            
            [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.tableView reloadData];
            } completion:nil];
        });
    }];
    
    [alert addAction:jsonDefault];
    [alert addAction:jsonMain];
    [alert addAction:sqliteMain];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_searchController.active) {
        return nil;
    } else {
        return [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        CGRect searchBarFrame = _searchController.searchBar.frame;
        [tableView scrollRectToVisible:searchBarFrame animated:true];
        return NSNotFound;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.active) {
        return _filteredCars.count;
    } else {
        return _carRow.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"carCell" forIndexPath:indexPath];
    if (_searchController.active) {
        CustomTableViewCell *carCell = (CustomTableViewCell *)cell;
        CarObject *car = _filteredCars[indexPath.row];
        carCell.carImage.image = car.image;
        carCell.carMarkLabel.text = car.mark;
        carCell.carModelLabel.text = car.model;
        carCell.carYearLabel.text = [NSString stringWithFormat:@"%i", (int)car.year];
        
        return carCell;
    } else {
        CustomTableViewCell *carCell = (CustomTableViewCell *)cell;
        CarObject *car = _carRow[indexPath.row];
        carCell.carImage.image = car.image;
        carCell.carMarkLabel.text = car.mark;
        carCell.carModelLabel.text = car.model;
        carCell.carYearLabel.text = [NSString stringWithFormat:@"%i", (int)car.year];
        
        return carCell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (_searchController.active) {
            CarObject *car = [_filteredCars objectAtIndex:indexPath.row];
            [_filteredCars removeObject:car];
            [_carRow removeObject:car];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [_carRow removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToEdit"]) {
        EditTableViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if (_searchController.active) {
            CarObject *car = _filteredCars[indexPath.row];
            vc.car = car;
        } else {
            CarObject *car = _carRow[indexPath.row];
            vc.car = car;
        }
    }
}

@end
