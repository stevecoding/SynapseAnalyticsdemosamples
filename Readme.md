# ACOM Synapse Demos

## Requirements
- Git & Git LFS.
- Azure Subscription. You can set up a [trial account](https://azure.microsoft.com/en-us/free/search/) here. 

## Clone the ACOM Synapse Demos Repository

Git will be used to copy all the files for the demo to your local computer.  

1. Install Git from [here](https://git-scm.com/download).
1. Install Git LFS from [here](https://help.github.com/en/github/managing-large-files/installing-git-large-file-storage)
    > IMPORTANT: Ensure you have Git LFS installed before cloning the repo or large files will be corrupt. If you find you have corrput files, you can run `git lfs pull` to download files in LFS.
1. Open a command prompt and navigate to a folder where the repo should be downloaded<br>
1. Issue the command `git clone https://github.com/stevecoding/SynapseAnalyticsdemosamples.git`

## Azure Resource Deployment

An Azure Resource Manager (ARM) template will be used to deploy all the required resources in the solution.  Click on the link below to start the deployment. Note that you may need to register Azure Resource Providers in order for the deployment to complete successfully.  If you get an error that a Resource Provider is not registered, you can register the Resource Provider by following the steps in this [link](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types) 

[![homepage](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fzarmada.blob.core.windows.net%2Farm-deployments-public%2Farm-template-acom.json "Deploy template")

### Deployment of resources

Follow the steps to deploy the required Azure resources.

Resources include:
- Azure Cosmos DB account
- Storage account
- Synapse workspace
- Apache Spark pool
- SQL Pool

**BASICS**  

   - **Subscription**: Select the Subscription.
   - **Resource group**:  Click on 'Create new' and provide a unique name for the Resource Group.
   - **Principal Id**: Deploying user principal id. Used to assign data access roles.
   - **Location**: Select the Region to deploy the resources. All resources will be deployed to this region. 
        > NOTE: This template has been confirmed to work within the **West US 2** region. If you wish to change the region, please ensure it supports the resources above. 

1. Read and accept the `TERMS AND CONDITIONS` by checking the box.
1. Click the `Purchase` button and wait for the deployment to finish.

## Post Deployment Configuration

Some resources require some extra configuration.

### Azure Cosmos DB

To upload the data to our Azure Cosmos DB we will leverage the Data Migration Tool. It can be downloaded from [here](https://aka.ms/csdmtool).

1. Open the **Dtui.exe** file from the Data Migration Tool folder.
1. Select the **CSV File(s)** option from the **Import from** dropdown menu.
1. Click the **Add Files** button and locate the `transactions.csv` file from the `data` folder of your project.
1. Click **Next**.
1. Update the **Connection String** value from the outputs of your deployment with the name `CosmosDB Connection String`. Append the connection string with `Database=InventoryDB;`
1. Update the **Collection** value to `sales`.
1. Expand the **Advanced Options** and set the **Number of Parallel Requests**  to 2.
1. Click **Next** until **Results** step.
1. Restart the process for a new import with the tool.
1. Select the **JSON File(s)** option from the **Import from** dropdown menu.
1. Click the **Add Files** button and locate the `inventory.json` file from the `data` folder of your project.
1. Click **Next**.
1. Update the **Connection String** value from the outputs of your deployment with the name `CosmosDB Connection String`.
1. Update the **Collection** value to `inventory`.
1. Expand the **Advanced Options** and set the **Number of Parallel Requests**  to 2.
1. Click **Next** until **Results** step.
 
### Storage setup

In this section we will setup our storage with the required folders and files.

1. In the [Azure portal](https://portal.azure.com/) select the **Resource Group** you created earlier.
1. Select the **Storage account** resource from the list.
1. Click the **Containers** option in the left menu under **Blob service**.
1. Click the **analytics** container.
1. Click the **+ Add Directory** button.
1. Enter the name `web_analytics`.
1. Click the **Save** button.
1. In the same way create this another 3 folders:
    * S3
    * SAP
    * customer_sales
1. Click the **web_analytics** folder.
1. Click the **Upload** button.
1. Click the **Select a file** input and select the file under the project folder: `data/web_analytics.parquet`.
1. Click the **Upload** button.
1. Once the file is uploaded, close the upload panel and go back to the folders list in the container clicking the **[..]** in the list.
1. Click the **customer_sales** folder.
1. Click the **Upload** button.
1. Click the **Select a file** input and select the file under the project folder: `data/customer_sales.parquet`.
1. Click the **Upload** button.
1. Once the file is uploaded, close the upload panel and go back to the folders list in the container clicking the **[..]** in the list.
1. Click the **S3** folder.
1. Click the **Upload** button.
1. Click the **Select a file** input and select the file under the project folder: `data/transactions.csv`.
1. Click the **Upload** button.
1. Once the file is uploaded, close the upload panel and go back to the folders list in the container clicking the **[..]** in the list.
1. Click the **SAP** folder.
1. Click the **Upload** button.
1. Click the **Select a file** input and select the file under the project folder: `data/customer.parquet`.
1. Click the **Upload** button.

### Synapse Workspace Setup

In this section we will setup our workspace with the required resources.

1. In the [Azure portal](https://portal.azure.com/) select the **Resource Group** you created earlier.
1. Select the **Synapse workspace** resource from the list.
1. Click the **Launch Synapse Studio** option.
1. Go over the setup of each section.

#### Datasets setup

Here we will setup the datasets that are required by the pipelines and other resources.

1. Click the **Data** icon on the left.
1. Click the **Linked** option to open the tab.

##### CustomerData Dataset

1. Click the **+** button.
1. Click the **Dataset** option in the menu.
1. Select the **Azure Data Lake Storage Gen2** option from the list.
1. Click the **Continue** button.
1. Click the **Parquet** option.
1. Click the **Continue** button.
1. Enter the name `CustomerData`.
1. Select the default storage for the **Linked service** option.
1. For the file path enter the following values for each input:
    * File System: `analytics`
    * Directory: `SAP`
    * File: `customer.parquet`
1. Click the **OK** button.
1. Click the **Publish all** button.
1. Click the **Publish** button.

##### TransactionData Dataset

1. Click the **+** button again.
1. Click the **Dataset** option in the menu.
1. Select the **Azure Data Lake Storage Gen2** option from the list.
1. Click the **Continue** button.
1. Click the **DelimitedText** option.
1. Click the **Continue** button.
1. Enter the name `TransactionData`.
1. Select the default storage for the **Linked service** option.
1. For the file path enter the following values for each input:
    * File System: `analytics`
    * Directory: `S3`
    * File: `transactions.csv`
1. Check the **First row as header** box.
1. Click the **OK** button.
1. Click the **Publish all** button.
1. Click the **Publish** button.

##### output_AggregatedSales Dataset

1. Click the **+** button again.
1. Click the **Dataset** option in the menu.
1. Select the **Azure Synapse Analytics (formerly SQL DW)** option from the list.
1. Click the **Continue** button.
1. Enter the name `output_AggregatedSales`.
1. Select the default sql server for the **Linked service** option.
1. Check the **Edit** checkbox for the **Table name** input.
1. Enter the value `dbo` in the first input and `AggregatedSales` in the second one.
1. Select the **None** option for the **Import schema** field.
1. Click the **OK** button.
1. In the **Connection** tab of the created Dataset find the input **DBName** and enter the value `sqlpool`.
1. Click the **Publish all** button.
1. Click the **Publish** button.

#### CosmosDB Linked service setup

Here we will setup the connection to the cosmos db.

1. Click the **Data** icon on the left.
1. Click the **+** button.
1. Click the **Connect to external data** option.
1. Click the **Azure Cosmos DB (SQL API)** option.
1. Rename to `CosmosDb`.
1. For the **Azure subscription** select the **Pay-As-You-Go({GUID})** option.
1. For the **Cosmos DB account name** select the account created in your resource group.
1. For the **Database name** select the **InventoryDB** option.
1. Click the **Create** button.

#### SQL scripts setup

Here we will setup the scripts to be use on our workspace.

1. Click the **Develop** icon on the left.
1. Click the **+** icon.
1. Select the **Import** from the menu.
1. Locate the following files from the `scripts` folder of your project:
    * `1 - setup-table - sqlpool.sql`
    * `2 - setup-security - sqlpool.sql`
    * `Execute As - sqlpool.sql`
    * `External Table - OnDemand.sql`
    * `Query Customer Engagement - OnDemand.sql`
    * `Query Customer Total Spent - OnDemand.sql`
    * `Query Spent by Region - OnDemand.sql`
1. Click the `1 - setup-table - sqlpool.sql` script to see it.
1. For the **Connect to** input select the **sqlpool** option.
1. Click the **Run** button and wait for the script to finish.
1. Click the `2 - setup-security - sqlpool.sql` script.
1. For the **Connect to** input select the **sqlpool** option.
1. Click the **Run** button and wait for the script to finish.
1. Update the Azure Storage account name in the following scripts:
    * `External Table - OnDemand.sql`
    * `Query Customer Engagement - OnDemand.sql`
    * `Query Customer Total Spent - OnDemand.sql`
    * `Query Spent by Region - OnDemand.sql`
1. Click the **Publish all** button.
1. Click the **Publish** button.

#### Dataflows setup

Here we will setup the scripts to be use on our workspace.

1. Click the **Develop** icon on the left.
1. Click the **+** icon.
1. Click the **Data flow** option.
1. Rename to `Mapping` before continue.
1. Click the **{}** button to see the code editor.
1. Get the content of the `dataflows/Mapping.json` file of your project and paste it to the editor.
1. Click the **OK** button.
1. Click the **Publish all** button.
1. Click the **Publish** button.

#### Notebook setup

Here we will setup the notebook of our workspace.

1. Click the **Develop** icon on the left.
1. Click the **+** button.
1. Click the **Import** option.
1. Locate the file `notebook/Stock draft-orders.ipynb` from your project folder.
1. Click the **Publish all** button.
1. Click the **Publish** button.

#### Pipelines setup

Here we will setup the pipelines of our workspace.

1. Click the **Orchestrate** icon on the left.
1. Click the **+** button.
1. Click the **Pipeline** option.
1. Rename the pipeline to `TwtPipeline`.
1. Click the **{}** button to see the code editor.
1. Get the content of the `pipelines/TwtPipeline.json` file of your project and paste it to the editor.
1. Click the **OK** button.
1. Click the **Publish all** button.
1. Click the **Publish** button.

## Demo Steps

1. Click the **Pipeline** pipeline from the list.
1. Click the **Add trigger** button.
1. Click the **Trigger now** option.
1. Click the **OK** button.
1. Click the **Monitor** option in the left menu.
1. Click the **Pipeline** run that should be `In progress` from the list.
1. Wait until the pipeline finish before continue.
>Note: This process can take between 5 to 7 minutes.
1. Click the **Develop** icon on the left.
1. Execute the scripts in the following order:
    * Note: The following scripts will target the SQL on-demand, therefore set **Connect to** to the **SQL on-demand** option for all of the scripts.
    * `Query Customer Total Spent - OnDemand.sql`
    * `Query Spent by Region - OnDemand.sql`
    * `Query Customer Engagement - OnDemand.sql`
1. Click the **Develop** icon on the left.
1. Open `Stock draft-orders`
1. Execute the notebook cell by cell.
