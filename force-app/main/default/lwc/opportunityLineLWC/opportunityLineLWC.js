import { LightningElement, api, wire, track } from "lwc";
import getProductEntries from "@salesforce/apex/OpportunityProductController.getProductEntries";
import addOpportunityProduct from "@salesforce/apex/OpportunityProductController.addOpportunityProduct";
import populateDataTable from "@salesforce/apex/OpportunityProductController.populateDataTable";
import getUnitPrice from "@salesforce/apex/OpportunityProductController.getUnitPrice";
import { refreshApex } from "@salesforce/apex";

const columns = [
  { label: "Product Name", fieldName: "PricebookEntry.Name", type: "text" },
  { label: "Quantity", fieldName: "Quantity", type: "number" }
];
export default class OpportunityLineLWC extends LightningElement {
  @api recordId;
  @track pricebookEntries = [];
  @track addedProducts = [];
  columns = columns;
  _wiredResult;
  error;
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
  @wire(populateDataTable, { opportunityId: "$recordId" })
  wiredProducts(result) {
    this._wiredResult = result;
    if (result.data) {
      this.addedProducts = result.data;
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.addedProducts = undefined;
    }
  }
  handleProductChange(event) {
    this.newLineItem.productId = event.target.value;
    getUnitPrice({ Product2Id: this.newLineItem.productId }).then((result) => {
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
    refreshApex(this.wiredProducts);
  }
}
