package org.springframework.samples.petclinic.vets.web;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.samples.petclinic.vets.model.Vet;
import org.springframework.samples.petclinic.vets.model.VetRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Juergen Hoeller
 * @author Mark Fisher
 * @author Ken Krebs
 * @author Arjen Poutsma
 * @author Maciej Szarlinski
 */
@RequestMapping("/vets")
@RestController
class VetResource {

    private static final Logger log = LoggerFactory.getLogger(VetResource.class);
    private final VetRepository vetRepository;

    VetResource(VetRepository vetRepository) {
        this.vetRepository = vetRepository;
    }

    @GetMapping
    @Cacheable("vets")
    public List<Vet> showResourcesVetList() {
        log.info("Fetching all vets from the repository");
        return vetRepository.findAll();
    }
}
