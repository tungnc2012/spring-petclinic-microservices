package org.springframework.samples.petclinic.customers.web;

import io.micrometer.core.annotation.Timed;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.samples.petclinic.customers.web.mapper.OwnerEntityMapper;
import org.springframework.samples.petclinic.customers.model.Owner;
import org.springframework.samples.petclinic.customers.model.OwnerRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * @author Juergen Hoeller
 * @author Ken Krebs
 * @author Arjen Poutsma
 * @author Michael Isvy
 * @author Maciej Szarlinski
 */
@RequestMapping("/owners")
@RestController
@Timed("petclinic.owner")
class OwnerResource {

    private static final Logger log = LoggerFactory.getLogger(OwnerResource.class);

    private final OwnerRepository ownerRepository;
    private final OwnerEntityMapper ownerEntityMapper;

    OwnerResource(OwnerRepository ownerRepository, OwnerEntityMapper ownerEntityMapper) {
        this.ownerRepository = ownerRepository;
        this.ownerEntityMapper = ownerEntityMapper;
    }

    /**
     * Create Owner
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Owner createOwner(@Valid @RequestBody OwnerRequest ownerRequest) {
        Owner owner = ownerEntityMapper.map(new Owner(), ownerRequest);
        log.info("Create new owner with information: {}", owner);        
        return ownerRepository.save(owner);
    }

    /**
     * Read single Owner
     */
    @GetMapping(value = "/{ownerId}")
    public Optional<Owner> findOwner(@PathVariable("ownerId") @Min(1) int ownerId) {
        log.info("Find owner with id {}", ownerId);
        return ownerRepository.findById(ownerId);
    }

    /**
     * Read List of Owners
     */
    @GetMapping
    public List<Owner> findAll() {
        return ownerRepository.findAll();
    }

    /**
     * Update Owner
     */
    @PutMapping(value = "/{ownerId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updateOwner(@PathVariable("ownerId") @Min(1) int ownerId, @Valid @RequestBody OwnerRequest ownerRequest) {
        final Owner ownerModel = ownerRepository.findById(ownerId).orElseThrow(() -> new ResourceNotFoundException("Owner " + ownerId + " not found"));

        ownerEntityMapper.map(ownerModel, ownerRequest);
        log.info("Edit owner information successfully. Saving owner {}", ownerModel);
        ownerRepository.save(ownerModel);
    }
}