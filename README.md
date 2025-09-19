 Membership Registry Smart Contract (Clarity)

A Clarity smart contract for managing **on-chain community memberships** with basic governance features.  
Built on [Stacks](https://www.stacks.co/), this contract provides a foundation for DAOs, clubs, gated communities, and tokenized organizations.

---

Features

- Join / Leave Membership**
  - Users register by paying a membership fee (in STX).
  - Members can leave at any time.
- Admin Controls
  - Admin can update membership fee.
  - Admin can promote/demote roles.
  - Admin can revoke members.
- Role Management
  - Each member is stored with a role and join timestamp.
- Treasury
  - Membership fees are stored in the contract balance.
  - Admin can withdraw funds (DAO voting integration planned).
- Read-Only Queries
  - Check membership status, role, admin, and fees.
