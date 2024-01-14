# Voting System

## Overview

This smart contract, `VotingSystem`, is designed to manage a simple voting system on the Ethereum blockchain. The contract facilitates the registration of voters, addition of candidates, casting of votes, and determination of the winner based on the maximum votes received by a candidate.

## Usage
Install foundry, Clone the repository and run

```bash
forge build
```

### Test Script

Run the command to execute the test script

```bash
forge script InteractVotingSystem
```
<Details>
<summary>Here is a step-by-step overview of the test script results</summary>


This test scenario involves the interaction with the `VotingSystem` smart contract using the `InteractVotingSystem` script. The script executes various functions, such as adding candidates, registering voters, casting votes, and picking the winner. Below is a step-by-step overview of the process:

### Step 1: Add Candidates
- The script initiates the `addCandidate` function, adding 5 candidates to the voting system.
- Logs display the count of candidates, indicating the successful addition.
  ```javascript
    1. Candidates count:  5
  ```

### Step 2: Register Voters
- The script initiates the `registerToVote` function, registering 10 voters.
- Logs display the number of successfully registered voters.
  ```javascript
  2. Voters Registered:  10
  ```

### Step 3: Cast Votes
- The script initiates the `vote` function, with each voter casting a vote for a randomly selected candidate.
- Logs display the association between each voter and the chosen candidate.
  ```javascript
  3. Voting
     voter0 -> 3
     voter1 -> 4
     voter2 -> 1
     voter3 -> 2
     voter4 -> 4
     voter5 -> 3
     voter6 -> 0
     voter7 -> 1
     voter8 -> 4
     voter9 -> 1
  ```

### Step 4: Pick Winner
- The script initiates the `pickWinner` function, triggering the determination of the winner based on the maximum votes received by a candidate.
- Logs display the winning candidate's name (`candidate1`) and the corresponding vote count (3).
    ```javascript
    4. Pick winner
   candidate1 with Votes 3
    ```
</Details>

### Tests

```bash
 forge test
```

## Design Choices

1. **Modularity:** The contract is designed with modularity in mind. Different stages of the voting process are encapsulated within separate functions and modifiers, making the contract flexible and easy to understand.

2. **Time-Based Phases:** The voting process is divided into distinct phases - candidate selection, voter registration, and voting. The contract uses time-based constraints to ensure that each phase occurs in the specified order. This design choice enhances the security and predictability of the voting system.

3. **Ownership Control:** The contract utilizes the Ownable pattern, where the deployer of the contract is the owner. This ownership control ensures that critical functions, such as adding candidates and determining the winner, can only be executed by the owner.

4. **Event Emission:** Events are emitted throughout the contract execution, providing transparency and allowing external applications to listen for important updates, such as voter registration, candidate addition, vote casting, and winner announcement.

5. **Error Handling:** The contract includes specific error messages for various exceptional conditions, improving the user experience and aiding developers in identifying and addressing issues.

## Security Considerations

1. **Only Externally Owned Accounts (EOA):** The `onlyEOA` modifier ensures that certain functions can only be called by externally owned accounts, enhancing security by preventing contract-to-contract calls.

2. **Time Constraints:** Time-based constraints are used to control the phases of the voting process. These constraints help prevent certain functions from being called outside the allowed time frames, reducing the risk of unauthorized actions.

3. **Input Validation:** Functions like `vote` and `addCandidate` include input validation to ensure that inputs are within acceptable ranges. This guards against potential vulnerabilities arising from unexpected inputs.

4. **Access Control:** The contract utilizes access control through the `onlyOwner` modifier, ensuring that critical functions are restricted to the owner. This prevents unauthorized individuals or contracts from manipulating the voting process.

5. **Event-Based State Changes:** Important state changes, such as marking a voter as registered or voted, are triggered by events. This design choice ensures that state changes are transparent and can be monitored by external observers.
