import { LightningElement, api, wire, track } from "lwc";
import getProductEntries from "@salesforce/apex/OpportunityProductController.getProductEntries";
import addOpportunityProduct from "@salesforce/apex/OpportunityProductController.addOpportunityProduct";
import populateDataTable from "@salesforce/apex/OpportunityProductController.populateDataTable";
import getUnitPrice from "@salesforce/apex/OpportunityProductController.getUnitPrice";

export default class OpportunityLineLWC extends LightningElement {
  @api recordId;
  @track pricebookEntries = [];
  @track addedProducts = [];
  @track newLineItem = {
    productId: "",
    quantity: 1,
    unitPrice: 0.0,
    pricebook2Id: "01sbm000004JhLWAA0"
  };

  connectedCallback() {
    this.fetchPricebookEntries();
  }

  fetchPricebookEntries() {
    getProductEntries({ pricebookId: "01sbm000004JhLWAA0" })
      .then((result) => {
        console.log("Pricebook Entries:", result);
        this.pricebookEntries = result.map((entry) => ({
          label: entry.Name,
          value: entry.Product2Id
        }));
      })
      .catch((error) => {
        console.error("Error fetching Pricebook Entries:", error);
      });
  }

  handleProductChange(event) {
    this.newLineItem.productId = event.target.value;
    getUnitPrice(this.newLineItem.productId).then((result) => {
      console.log(result);
      this.newLineItem.unitPrice = result;
    });
    console.log(this.newLineItem.unitPrice);
  }

  handleQuantityChange(event) {
    this.newLineItem.quantity = event.target.value;
  }

  addLineItem() {
    const lineItem = {
      OpportunityId: this.recordId,
      Product2Id: this.newLineItem.productId,
      Quantity: this.newLineItem.quantity,
      UnitPrice: this.newLineItem.unitPrice,
      Pricebook2Id: this.newLineItem.pricebook2Id
    };
    console.log("Line Item Opportunity ", lineItem.OpportunityId);
    console.log("Line Item Product Id ", lineItem.Product2Id);
    console.log("Line Item Quantity ", lineItem.Quantity);
    console.log("Line Item Unit Price", lineItem.UnitPrice);
    console.log("Line Item PriceBookId ", lineItem.Pricebook2Id);
    addOpportunityProduct({
      opportunityId: this.recordId,
      products: [lineItem]
    })
      .then(() => {
        // Handle success
        console.log("Opportunity Line Item added");
      })
      .catch((error) => {
        console.error("Error adding Opportunity Line Item:", error);
      });
    populateDataTable({ opportunityId: this.recordId }).then((result) => {
      console.log("Products: ", result);
      this.addedProducts = result;
    });
  }
}
