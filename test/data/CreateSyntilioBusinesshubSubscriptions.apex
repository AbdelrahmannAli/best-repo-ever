List<Account> accounts = [
 SELECT Id 
 FROM Account
];

Contact patientContactJohan = [SELECT Id FROM Contact WHERE LastName ='Hendrik'];
Contact patientContactKarelGroenendijk = [SELECT Id FROM Contact WHERE LastName = 'Groenendijk'];
Contact patientContactPieter = [SELECT Id FROM Contact WHERE LastName ='Dirk'];

Account envidaCare = [SELECT Id FROM Account WHERE Name = 'Envida'];
Account twbCare = [SELECT Id FROM Account WHERE Syntilio__ApiName__c = 'Twb'];

Contract contracenvidaCare = new Contract();
contracenvidaCare.Status = 'Draft';
contracenvidaCare.StartDate = date.today();
contracenvidaCare.ContractTerm = 12;
contracenvidaCare.AccountId = envidaCare.Id;

insert contracenvidaCare;

Contract contractTwbCare = new Contract();
contractTwbCare.Status = 'Draft';
contractTwbCare.StartDate = date.today();
contractTwbCare.ContractTerm = 12;
contractTwbCare.AccountId = twbCare.Id;

insert contractTwbCare;

List<Product2> subscriptionProducts = new List<Product2>();
List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

Product2 begeleidingBasisInBegeleiding = new Product2();
begeleidingBasisInBegeleiding.Name = 'Begeleiding Basis';
begeleidingBasisInBegeleiding.IsActive = true;
begeleidingBasisInBegeleiding.Syntilio__IsSubscription__c = true;
begeleidingBasisInBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone';
begeleidingBasisInBegeleiding.Syntilio__Minutes__c = 2;
begeleidingBasisInBegeleiding.Syntilio__PricePerWeek__c = 3.30;
begeleidingBasisInBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(begeleidingBasisInBegeleiding);

Product2 begeleidingWaakvlamInBegeleiding = new Product2();
begeleidingWaakvlamInBegeleiding.Name = 'Begeleiding Waakvlam';
begeleidingWaakvlamInBegeleiding.IsActive = true;
begeleidingWaakvlamInBegeleiding.Syntilio__IsSubscription__c = true;
begeleidingWaakvlamInBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone';
begeleidingWaakvlamInBegeleiding.Syntilio__Minutes__c = 5;
begeleidingWaakvlamInBegeleiding.Syntilio__PricePerWeek__c = 7.85;
begeleidingWaakvlamInBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(begeleidingWaakvlamInBegeleiding);

Product2 begeleiding1InBegeleiding = new Product2();
begeleiding1InBegeleiding.Name = 'Begeleiding 1';
begeleiding1InBegeleiding.IsActive = true;
begeleiding1InBegeleiding.Syntilio__IsSubscription__c = true;
begeleiding1InBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone;Video';
begeleiding1InBegeleiding.Syntilio__Minutes__c = 15;
begeleiding1InBegeleiding.Syntilio__PricePerWeek__c = 15;
begeleiding1InBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(begeleiding1InBegeleiding);

Product2 begeleiding2InBegeleiding = new Product2();
begeleiding2InBegeleiding.Name = 'Begeleiding 2';
begeleiding2InBegeleiding.IsActive = true;
begeleiding2InBegeleiding.Syntilio__IsSubscription__c = true;
begeleiding2InBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone;Video';
begeleiding2InBegeleiding.Syntilio__Minutes__c = 30;
begeleiding2InBegeleiding.Syntilio__PricePerWeek__c = 30;
begeleiding2InBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(begeleiding2InBegeleiding);

Product2 begeleiding3InBegeleiding = new Product2();
begeleiding3InBegeleiding.Name = 'Begeleiding 3';
begeleiding3InBegeleiding.IsActive = true;
begeleiding3InBegeleiding.Syntilio__IsSubscription__c = true;
begeleiding3InBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone;Video';
begeleiding3InBegeleiding.Syntilio__Minutes__c = 45;
begeleiding3InBegeleiding.Syntilio__PricePerWeek__c = 45;
begeleiding3InBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(begeleiding3InBegeleiding);

Product2 begeleiding4InBegeleiding = new Product2();
begeleiding4InBegeleiding.Name = 'Begeleiding 4';
begeleiding4InBegeleiding.IsActive = true;
begeleiding4InBegeleiding.Syntilio__IsSubscription__c = true;
begeleiding4InBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone;Video';
begeleiding4InBegeleiding.Syntilio__Minutes__c = 60;
begeleiding4InBegeleiding.Syntilio__PricePerWeek__c = 60;
begeleiding4InBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(begeleiding4InBegeleiding);


Product2 specialistisch1InBegeleiding = new Product2();
specialistisch1InBegeleiding.Name = 'Specialistisch 1';
specialistisch1InBegeleiding.IsActive = true;
specialistisch1InBegeleiding.Syntilio__IsSubscription__c = true;
specialistisch1InBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone;Video';
specialistisch1InBegeleiding.Syntilio__Minutes__c = 90;
specialistisch1InBegeleiding.Syntilio__PricePerWeek__c = 97.5;
specialistisch1InBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(specialistisch1InBegeleiding);

Product2 specialistisch2InBegeleiding = new Product2();
specialistisch2InBegeleiding.Name = 'Specialistisch 2';
specialistisch2InBegeleiding.IsActive = true;
specialistisch2InBegeleiding.Syntilio__IsSubscription__c = true;
specialistisch2InBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone;Video';
specialistisch2InBegeleiding.Syntilio__Minutes__c = 120;
specialistisch2InBegeleiding.Syntilio__PricePerWeek__c = 130;
specialistisch2InBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(specialistisch2InBegeleiding);

Product2 specialistisch3InBegeleiding = new Product2();
specialistisch3InBegeleiding.Name = 'Specialistisch 3';
specialistisch3InBegeleiding.IsActive = true;
specialistisch3InBegeleiding.Syntilio__IsSubscription__c = true;
specialistisch3InBegeleiding.Syntilio__AddOns__c = 'Audio;Telephone;Video';
specialistisch3InBegeleiding.Syntilio__Minutes__c = 150;
specialistisch3InBegeleiding.Syntilio__PricePerWeek__c = 162.5;
specialistisch3InBegeleiding.Family = 'Begeleiding';

subscriptionProducts.add(specialistisch3InBegeleiding);


Product2 verpleegkundigLichtInVerpleegkundig = new Product2();
verpleegkundigLichtInVerpleegkundig.Name = 'Verpleegkundig Licht';
verpleegkundigLichtInVerpleegkundig.IsActive = true;
verpleegkundigLichtInVerpleegkundig.Syntilio__IsSubscription__c = true;
verpleegkundigLichtInVerpleegkundig.Syntilio__AddOns__c = 'Audio;Telephone;Video';
verpleegkundigLichtInVerpleegkundig.Syntilio__Minutes__c = null;
verpleegkundigLichtInVerpleegkundig.Syntilio__PricePerWeek__c = 3.93;
verpleegkundigLichtInVerpleegkundig.Family = 'Verpleegkundig';

subscriptionProducts.add(verpleegkundigLichtInVerpleegkundig);

Product2 verpleegkundigMiddelInVerpleegkundig = new Product2();
verpleegkundigMiddelInVerpleegkundig.Name = 'Verpleegkundig Middel';
verpleegkundigMiddelInVerpleegkundig.IsActive = true;
verpleegkundigMiddelInVerpleegkundig.Syntilio__IsSubscription__c = true;
verpleegkundigMiddelInVerpleegkundig.Syntilio__AddOns__c = 'Audio;Telephone;Video';
verpleegkundigMiddelInVerpleegkundig.Syntilio__Minutes__c = null;
verpleegkundigMiddelInVerpleegkundig.Syntilio__PricePerWeek__c = 6.21;
verpleegkundigMiddelInVerpleegkundig.Family = 'Verpleegkundig';

subscriptionProducts.add(verpleegkundigMiddelInVerpleegkundig);

Product2 verpleegkundigZwaarInVerpleegkundig = new Product2();
verpleegkundigZwaarInVerpleegkundig.Name = 'Verpleegkundig Zwaar';
verpleegkundigZwaarInVerpleegkundig.IsActive = true;
verpleegkundigZwaarInVerpleegkundig.Syntilio__IsSubscription__c = true;
verpleegkundigZwaarInVerpleegkundig.Syntilio__AddOns__c = 'Audio;Telephone;Video';
verpleegkundigZwaarInVerpleegkundig.Syntilio__Minutes__c = null;
verpleegkundigZwaarInVerpleegkundig.Syntilio__PricePerWeek__c = 11.10;
verpleegkundigZwaarInVerpleegkundig.Family = 'Verpleegkundig';

subscriptionProducts.add(verpleegkundigZwaarInVerpleegkundig);


Product2 consultatiedienstLichtInConsultatiediensten = new Product2();
consultatiedienstLichtInConsultatiediensten.Name = 'Consultatiedienst Licht';
consultatiedienstLichtInConsultatiediensten.IsActive = true;
consultatiedienstLichtInConsultatiediensten.Syntilio__IsSubscription__c = true;
consultatiedienstLichtInConsultatiediensten.Syntilio__AddOns__c = 'Audio;Telephone;Video';
consultatiedienstLichtInConsultatiediensten.Syntilio__Minutes__c = null;
consultatiedienstLichtInConsultatiediensten.Syntilio__PricePerWeek__c = 0.50;
consultatiedienstLichtInConsultatiediensten.Family = 'Consultatiediensten';

subscriptionProducts.add(consultatiedienstLichtInConsultatiediensten);

Product2 consultatiedienstMiddelInConsultatiediensten = new Product2();
consultatiedienstMiddelInConsultatiediensten.Name = 'Consultatiedienst Middel';
consultatiedienstMiddelInConsultatiediensten.IsActive = true;
consultatiedienstMiddelInConsultatiediensten.Syntilio__IsSubscription__c = true;
consultatiedienstMiddelInConsultatiediensten.Syntilio__AddOns__c = 'Audio;Telephone;Video';
consultatiedienstMiddelInConsultatiediensten.Syntilio__Minutes__c = null;
consultatiedienstMiddelInConsultatiediensten.Syntilio__PricePerWeek__c = 0.90;
consultatiedienstMiddelInConsultatiediensten.Family = 'Consultatiediensten';

subscriptionProducts.add(consultatiedienstMiddelInConsultatiediensten);

Product2 consultatiedienstZwaarInConsultatiediensten = new Product2();
consultatiedienstZwaarInConsultatiediensten.Name = 'Consultatiedienst Zwaar';
consultatiedienstZwaarInConsultatiediensten.IsActive = true;
consultatiedienstZwaarInConsultatiediensten.Syntilio__IsSubscription__c = true;
consultatiedienstZwaarInConsultatiediensten.Syntilio__AddOns__c = 'Audio;Telephone;Video';
consultatiedienstZwaarInConsultatiediensten.Syntilio__Minutes__c = null;
consultatiedienstZwaarInConsultatiediensten.Syntilio__PricePerWeek__c = 3.30;
consultatiedienstZwaarInConsultatiediensten.Family = 'Consultatiediensten';

subscriptionProducts.add(consultatiedienstZwaarInConsultatiediensten);

insert subscriptionProducts;


Pricebook2 standardPriceBookReal = null;
// Start inserting price books
Pricebook2[] standardPriceBook = [
    SELECT Id
    FROM Pricebook2
    WHERE IsStandard = true
];

if(standardPriceBook.size() == 0) {
    Pricebook2 newStandardPriceBook = new Pricebook2();
    newStandardPriceBook.IsActive = false;
    newStandardPriceBook.Description = 'Standard price book';
    newStandardPriceBook.Name = 'New Standard Price Book';
    insert newStandardPriceBook;

    standardPriceBookReal = newStandardPriceBook;
} else {
    standardPriceBookReal = standardPriceBook[0];
}

// List<Pricebook2> newPriceBooks = new List<Pricebook2>();
List<PricebookEntry> newPriceBookEntries = new List<PricebookEntry>();

Pricebook2 digiContactPriceBook = new Pricebook2();
digiContactPriceBook.Name = 'DigiContact 2024';
digiContactPriceBook.IsActive = true;

insert digiContactPriceBook;

// Start creating standard price book entries
for(Product2 subscriptionItem :subscriptionProducts) {
    PricebookEntry newPriceBookEntry = new PricebookEntry();
    newPriceBookEntry.Product2Id = subscriptionItem.Id;
    newPriceBookEntry.Pricebook2Id = standardPriceBookReal.Id;
    newPriceBookEntry.IsActive = false;
    newPriceBookEntry.UnitPrice = 24;

    newPriceBookEntries.add(newPriceBookEntry);

    Id digiContactPricebook2Id = digiContactPriceBook.Id;
    // Id pricebook2Id = subscriptionItem.Name.contains('Consultatiedienst') ? consultatiedienstPriceBook.Id : subscriptionItem.Name.contains('Verpleegkundig') ? verpleegkundigPriceBook.Id : subscriptionItem.Name.contains('Begeleiding') ? begeleidingPriceBook.Id : null;
    if(digiContactPricebook2Id != null ){
        PricebookEntry newPriceBookEntryWithRespectivePriceBook = new PricebookEntry();
        newPriceBookEntryWithRespectivePriceBook.Product2Id = subscriptionItem.Id;
        newPriceBookEntryWithRespectivePriceBook.Pricebook2Id = digiContactPricebook2Id;
        newPriceBookEntryWithRespectivePriceBook.UnitPrice = subscriptionItem.Syntilio__PricePerWeek__c;
        newPriceBookEntryWithRespectivePriceBook.IsActive = true;

        newPriceBookEntries.add(newPriceBookEntryWithRespectivePriceBook);
    }
}

insert newPriceBookEntries;

/*
Order order = new Order();
order.AccountId = a.envidaCare;
order.EffectiveDate = date.today();
order.ContractId = contract.Id;
order.Status = 'Draft';
order.BillToContactId = c1.Id;

insert order;

Order order2 = new Order();
order2.AccountId = a.Id;
order2.EffectiveDate = date.today();
order2.ContractId = contract.Id;
order2.Status = 'Draft';
order2.BillToContactId = c2.Id;

insert order2;

List<Product2> products = [SELECT Id FROM Product2];

OrderItem orderItem = new OrderItem();
orderItem.OrderId = order.Id;
orderItem.Product2Id = products[0].Id;
orderItem.ListPrice = 100;
orderItem.UnitPrice = 100;
orderItem.Quantity = 1;

insert orderItem;

OrderItem orderItem2 = new OrderItem();
orderItem2.OrderId = order.Id;
orderItem2.Product2Id = products[1].Id;
orderItem2.ListPrice = 200;
orderItem2.UnitPrice = 200;
orderItem2.Quantity = 2;

insert orderItem2;

OrderItem orderItem3 = new OrderItem();
orderItem3.OrderId = order2.Id;
orderItem3.Product2Id = products[2].Id;
orderItem3.ListPrice = 300;
orderItem3.UnitPrice = 300;
orderItem3.Quantity = 3;

insert orderItem3;


Product2 wakklvam = new Product2();
wakklvam.Name = 'Wakklvam';
wakklvam.IsActive = true;
wakklvam.Syntilio__AddOns__c = 'Audio;Telephone';
wakklvam.Syntilio__Minutes__c = 5;
wakklvam.Family = 'Subscriptions';
wakklvam.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(wakklvam);


Product2 licht = new Product2();
licht.Name = 'Licht';
licht.IsActive = true;
licht.Syntilio__AddOns__c = 'Video;Audio;Telephone';
licht.Syntilio__Minutes__c = 15;
licht.Family = 'Subscriptions';
licht.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(licht);


Product2 regulier = new Product2();
regulier.Name = 'Regulier';
regulier.IsActive = true;
regulier.Syntilio__AddOns__c = 'Video;Audio;Telephone';
regulier.Syntilio__Minutes__c = 30;
regulier.Family = 'Subscriptions';
regulier.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(regulier);


Product2 xyzNaam = new Product2();
xyzNaam.Name = 'XYZ Naam';
xyzNaam.IsActive = true;
xyzNaam.Syntilio__AddOns__c = 'Video;Audio;Telephone';
xyzNaam.Syntilio__Minutes__c = 45;
xyzNaam.Family = 'Subscriptions';
xyzNaam.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(xyzNaam);

Product2 intensief = new Product2();
intensief.Name = 'Intensief';
intensief.IsActive = true;
intensief.Syntilio__AddOns__c = 'Video;Audio;Telephone';
intensief.Syntilio__Minutes__c = 60;
intensief.Family = 'Subscriptions';
intensief.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(intensief);

Product2 specialistisch1 = new Product2();
specialistisch1.Name = 'Specialistisch 1';
specialistisch1.IsActive = true;
specialistisch1.Syntilio__AddOns__c = 'Video;Audio;Telephone';
specialistisch1.Syntilio__Minutes__c = 90;
specialistisch1.Family = 'Subscriptions';
specialistisch1.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(specialistisch1);

Product2 specialistisch2 = new Product2();
specialistisch2.Name = 'Specialistisch 2';
specialistisch2.IsActive = true;
specialistisch2.Syntilio__AddOns__c = 'Video;Audio;Telephone';
specialistisch2.Syntilio__Minutes__c = 120;
specialistisch2.Family = 'Subscriptions';
specialistisch2.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(specialistisch2);

Product2 specialistisch3 = new Product2();
specialistisch3.Name = 'Specialistisch 3';
specialistisch3.IsActive = true;
specialistisch3.Syntilio__AddOns__c = 'Video;Audio;Telephone';
specialistisch3.Syntilio__Minutes__c = 150;
specialistisch3.Family = 'Subscriptions';
specialistisch3.Syntilio__IsSubscription__c = true;
subscriptionProducts.add(specialistisch3);

insert subscriptionProducts;

List<Pricebook2> newPricebook = [SELECT Id FROM Pricebook2 WHERE isStandard=true];

for(Product2 subscription : subscriptionProducts) {
    PricebookEntry newPricebookEntry = new PricebookEntry();
    newPricebookEntry.Pricebook2Id = newPricebook[0].Id;
    newPricebookEntry.Product2Id =subscription.Id;
    newPricebookEntry.IsActive = true;
    newPricebookEntry.UnitPrice = 500;
    pricebookEntries.add(newPricebookEntry);
}

insert pricebookEntries;


*/