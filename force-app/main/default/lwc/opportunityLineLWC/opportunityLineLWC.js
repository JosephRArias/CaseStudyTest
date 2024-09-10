import { LightningElement, api, wire, track } from "lwc";
import getProductEntries from "@salesforce/apex/OpportunityProductController.getProductEntries";
import addOpportunityProduct from "@salesforce/apex/OpportunityProductController.addOpportunityProduct";

export default class OpportunityLineLWC extends LightningElement {
  @api recordId;
  @track pricebookEntries = [];
  @track newLineItem = {
    productId: "",
    quantity: 1,
    unitPrice: 0
  };

  connectedCallback() {
    this.fetchPricebookEntries();
  }

  fetchPricebookEntries() {
    getProductEntries({ pricebookId: "01sbm000004JhLWAA0" })
      .then((result) => {
        this.pricebookEntries = result;
      })
      .catch((error) => {
        console.error("Error fetching Pricebook Entries:", error);
      });
  }

  handleProductChange(event) {
    this.newLineItem.productId = event.target.value;
  }

  handleQuantityChange(event) {
    this.newLineItem.quantity = event.target.value;
  }

  handleUnitPriceChange(event) {
    this.newLineItem.unitPrice = event.target.value;
  }

  addLineItem() {
    const lineItem = {
      OpportunityId: this.recordId,
      Product2Id: this.newLineItem.productId,
      Quantity: this.newLineItem.quantity,
      UnitPrice: this.newLineItem.unitPrice
    };

    addOpportunityProduct({
      opportunityId: this.recordId,
      newLineItems: [lineItem]
    })
      .then(() => {
        // Handle success
        console.log("Opportunity Line Item added");
      })
      .catch((error) => {
        console.error("Error adding Opportunity Line Item:", error);
      });
  }
}
